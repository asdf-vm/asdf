package git

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/asdf-vm/asdf/internal/repotest"
	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/stretchr/testify/assert"
)

func TestIsSHA(t *testing.T) {
	tests := []struct {
		name     string
		ref      string
		expected bool
	}{
		{"Full SHA", "907ef6a8bc38f144f041e888109ed301dc3d8aaa", true},
		{"Short SHA 7 chars", "907ef6a", true},
		{"Short SHA 8 chars", "907ef6a8", true},
		{"Short SHA 12 chars", "907ef6a8bc38", true},
		{"Branch name", "main", false},
		{"Branch with numbers", "v1.2.3", false},
		{"Tag", "v1.0.0", false},
		{"Tag with numbers", "1.0.0", false},
		{"Mixed case", "907EF6A", false},                                 // SHA should be lowercase
		{"Too short", "907ef6", false},                                   // Less than 7 chars
		{"Too long", "907ef6a8bc38f144f041e888109ed301dc3d8aaab", false}, // More than 40 chars
		{"With special chars", "907ef6a#", false},
		{"Empty string", "", false},
		{"Only numbers", "1234567", true},        // Valid hex (numbers 0-9 are valid hex)
		{"Letters and numbers", "abc1234", true}, // Valid hex
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := isSHA(tt.ref)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestRepoClone(t *testing.T) {
	t.Run("when repo name is valid but URL is invalid prints an error", func(t *testing.T) {
		repo := NewRepo(t.TempDir())
		err := repo.Clone("foobar", "")

		assert.ErrorContains(t, err, "unable to clone plugin: fatal: repository 'foobar' does not exist")
	})

	t.Run("clones provided Git URL to repo directory when URL is valid", func(t *testing.T) {
		repoDir := generateRepo(t)
		directory := t.TempDir()
		repo := NewRepo(directory)

		err := repo.Clone(repoDir, "")
		assert.Nil(t, err)

		// Assert repo directory contains Git repo with bin directory
		_, err = os.ReadDir(directory + "/.git")
		assert.Nil(t, err)

		entries, err := os.ReadDir(directory + "/bin")
		assert.Nil(t, err)
		assert.Equal(t, 12, len(entries))
	})

	t.Run("when repo name and URL are valid but ref is invalid prints an error", func(t *testing.T) {
		repoDir := generateRepo(t)
		directory := t.TempDir()
		repo := NewRepo(directory)

		err := repo.Clone(repoDir, "non-existent")

		assert.ErrorContains(t, err, "unable to clone plugin: fatal: Remote branch non-existent not found in upstream origin")
	})

	t.Run("clones a provided Git URL and checks out a specific ref when URL is valid and ref is provided", func(t *testing.T) {
		repoDir := generateRepo(t)
		directory := t.TempDir()
		repo := NewRepo(directory)

		err := repo.Clone(repoDir, "master")
		assert.Nil(t, err)

		// Assert repo directory contains Git repo with bin directory
		_, err = os.ReadDir(directory + "/.git")
		assert.Nil(t, err)

		entries, err := os.ReadDir(directory + "/bin")
		assert.Nil(t, err)
		assert.Equal(t, 12, len(entries))
	})
}

func TestRepoHead(t *testing.T) {
	repoDir := generateRepo(t)
	directory := t.TempDir()

	repo := NewRepo(directory)

	err := repo.Clone(repoDir, "")
	assert.Nil(t, err)

	head, err := repo.Head()

	assert.Nil(t, err)
	assert.NotZero(t, head)
}

func TestRepoRemoteURL(t *testing.T) {
	repoDir := generateRepo(t)
	directory := t.TempDir()

	repo := NewRepo(directory)

	err := repo.Clone(repoDir, "")
	assert.Nil(t, err)

	url, err := repo.RemoteURL()
	assert.Nil(t, err)
	assert.NotZero(t, url)
}

func TestRepoUpdate(t *testing.T) {
	repoDir := generateRepo(t)
	directory := t.TempDir()

	repo := NewRepo(directory)

	err := repo.Clone(repoDir, "")
	assert.Nil(t, err)

	t.Run("returns error when repo with name does not exist", func(t *testing.T) {
		nonexistentPath := filepath.Join(directory, "nonexistent")
		nonexistentRepo := NewRepo(nonexistentPath)
		updatedToRef, _, _, err := nonexistentRepo.Update("")

		assert.NotNil(t, err)
		assert.Equal(t, updatedToRef, "")
		assert.ErrorContains(t, err, "no such file or directory")
	})

	t.Run("returns error when repo repo does not exist", func(t *testing.T) {
		badRepoDir := t.TempDir()
		badRepo := NewRepo(badRepoDir)

		updatedToRef, _, _, err := badRepo.Update("")

		assert.NotNil(t, err)
		assert.Equal(t, updatedToRef, "")
		expectedErrMsg := "not a git repository"
		assert.ErrorContains(t, err, expectedErrMsg)
	})

	t.Run("does not return error when repo is already updated", func(t *testing.T) {
		// update repo twice to test already updated case
		updatedToRef, _, _, err := repo.Update("")
		assert.Nil(t, err)
		updatedToRef2, oldHash, newHash, err := repo.Update("")
		assert.Nil(t, err)
		assert.Equal(t, updatedToRef, updatedToRef2)
		assert.Equal(t, oldHash, newHash)
	})

	t.Run("updates repo when repo when repo exists", func(t *testing.T) {
		latestHash, err := getCurrentCommit(directory)
		assert.Nil(t, err)

		_, err = checkoutPreviousCommit(directory)
		assert.Nil(t, err)

		updatedToRef, _, _, err := repo.Update("")
		assert.Nil(t, err)
		assert.Equal(t, "refs/heads/master", updatedToRef)

		currentHash, err := getCurrentCommit(directory)
		assert.Nil(t, err)
		assert.Equal(t, latestHash, currentHash)
	})

	t.Run("updates repo while leaving untracked files in place", func(t *testing.T) {
		latestHash, err := getCurrentCommit(directory)
		assert.Nil(t, err)

		_, err = checkoutPreviousCommit(directory)
		assert.Nil(t, err)

		untrackedDir := filepath.Join(directory, "untracked")
		err = os.Mkdir(untrackedDir, 0o777)
		assert.Nil(t, err)

		expectedContent := []byte("dummy_content")
		err = os.WriteFile(filepath.Join(untrackedDir, "file_one"), expectedContent, 0o777)
		assert.Nil(t, err)
		err = os.WriteFile(filepath.Join(untrackedDir, "file_two"), expectedContent, 0o777)
		assert.Nil(t, err)

		updatedToRef, _, _, err := repo.Update("")
		assert.Nil(t, err)
		assert.Equal(t, "refs/heads/master", updatedToRef)

		currentHash, err := getCurrentCommit(directory)
		assert.Nil(t, err)
		assert.Equal(t, latestHash, currentHash)

		content, err := os.ReadFile(filepath.Join(untrackedDir, "file_one"))
		assert.Nil(t, err)
		assert.Equal(t, expectedContent, content)

		content, err = os.ReadFile(filepath.Join(untrackedDir, "file_two"))
		assert.Nil(t, err)
		assert.Equal(t, expectedContent, content)
	})

	t.Run("Returns error when specified ref does not exist", func(t *testing.T) {
		ref := "non-existent"
		updatedToRef, _, _, err := repo.Update(ref)
		assert.Equal(t, updatedToRef, "")
		expectedErrMsg := "fatal: couldn't find remote ref non-existent"
		assert.ErrorContains(t, err, expectedErrMsg)
	})

	t.Run("updates repo to ref when repo with name and ref exist", func(t *testing.T) {
		ref := "master"

		hash, err := getCommit(directory, ref)
		assert.Nil(t, err)

		updatedToRef, _, newHash, err := repo.Update(ref)
		assert.Nil(t, err)
		assert.Equal(t, "master", updatedToRef)

		// Check that repo was updated to ref
		latestHash, err := getCurrentCommit(directory)
		assert.Nil(t, err)
		assert.Equal(t, hash, latestHash)
		assert.Equal(t, newHash, latestHash)
	})
}

func getCurrentCommit(path string) (string, error) {
	return getCommit(path, "HEAD")
}

func getCommit(path, revision string) (string, error) {
	repo, err := git.PlainOpen(path)
	if err != nil {
		return "", err
	}

	hash, err := repo.ResolveRevision(plumbing.Revision(revision))

	return hash.String(), err
}

func checkoutPreviousCommit(path string) (string, error) {
	repo, err := git.PlainOpen(path)
	if err != nil {
		return "", err
	}

	previousHash, err := repo.ResolveRevision(plumbing.Revision("HEAD~"))
	if err != nil {
		return "", err
	}

	worktree, err := repo.Worktree()
	if err != nil {
		return "", err
	}

	err = worktree.Reset(&git.ResetOptions{Commit: *previousHash})
	if err != nil {
		return "", err
	}

	return previousHash.String(), nil
}

func generateRepo(t *testing.T) string {
	t.Helper()
	tempDir := t.TempDir()
	path, err := repotest.GeneratePlugin("dummy_plugin", tempDir, "lua")

	assert.Nil(t, err)
	return path
}

func TestIsURL(t *testing.T) {
	// Create temporary directory for testing file existence
	tempDir := t.TempDir()
	
	// Create test files and directories
	existingFile := filepath.Join(tempDir, "existing-file")
	err := os.WriteFile(existingFile, []byte("test"), 0644)
	assert.Nil(t, err)
	
	existingDir := filepath.Join(tempDir, "existing-dir")
	err = os.Mkdir(existingDir, 0755)
	assert.Nil(t, err)
	
	nestedExistingDir := filepath.Join(tempDir, "nested", "dir")
	err = os.MkdirAll(nestedExistingDir, 0755)
	assert.Nil(t, err)
	
	// Create a path that looks like a branch but exists as file
	branchLikeFile := filepath.Join(tempDir, "feature", "new-ui")
	err = os.MkdirAll(filepath.Dir(branchLikeFile), 0755)
	assert.Nil(t, err)
	err = os.WriteFile(branchLikeFile, []byte("test"), 0644)
	assert.Nil(t, err)
	
	// Create files/dirs that look like common branch names
	mainDir := filepath.Join(tempDir, "main")
	err = os.Mkdir(mainDir, 0755)
	assert.Nil(t, err)
	
	developFile := filepath.Join(tempDir, "develop")
	err = os.WriteFile(developFile, []byte("test"), 0644)
	assert.Nil(t, err)

	tests := []struct {
		name     string
		input    string
		expected bool
	}{
		// HTTP/HTTPS URLs
		{"HTTP URL", "http://github.com/user/repo.git", true},
		{"HTTPS URL", "https://github.com/user/repo.git", true},
		{"HTTPS URL without .git", "https://github.com/user/repo", true},
		{"Invalid HTTP missing colon", "http//example.com", false}, // Fixed: should be false

		// Git protocol
		{"Git protocol", "git://github.com/user/repo.git", true},

		// SSH protocol variants
		{"SSH full URL", "ssh://git@github.com/user/repo.git", true},
		{"SSH shorthand", "git@github.com:user/repo.git", true},
		{"SSH shorthand without .git", "git@github.com:user/repo", true},
		{"SSH with different user", "user@example.com:project/repo.git", true},
		{"SSH-like but with spaces", "git@github.com: user/repo", false}, // Fixed: should be false

		// File protocol
		{"File protocol", "file:///path/to/repo", true},

		// Local file paths - absolute paths (always URLs regardless of existence)
		{"Absolute path", "/home/user/repo", true},
		{"Absolute path with spaces", "/home/user/my repo", true},
		{"Root path", "/", true},

		// Explicit relative paths (always URLs regardless of existence)  
		{"Relative path with ./", "./repo", true},
		{"Parent directory with ../", "../repo", true},
		{"Nested relative path with ./", "./projects/myrepo", true},
		{"Parent then child with ../", "../projects/myrepo", true},

		// Windows paths (always URLs)
		{"Windows absolute path", "C:\\Users\\repo", true},
		{"Windows absolute path forward slash", "C:/Users/repo", true},
		{"Windows different drive", "D:\\projects\\repo", true},

		// File existence tests - any name could be a file or git ref
		{"Existing file with slash", branchLikeFile, true}, // Should be URL because file exists
		{"Existing directory", nestedExistingDir, true},    // Should be URL because dir exists
		{"Non-existing path with slash", "nonexistent/path", false}, // Should be branch because doesn't exist (relative path)
		{"Branch-like name that exists as dir", mainDir, true}, // Should be URL because dir exists
		{"Branch-like name that exists as file", developFile, true}, // Should be URL because file exists
		
		// Git references that don't exist as files (should return false)
		{"Branch name main", "main", false}, // Common branch name, doesn't exist as file
		{"Branch name develop", "develop", false}, // Common branch name, doesn't exist as file
		{"Branch name with dash", "feature-branch", false},
		{"Branch name with underscore", "feature_branch", false},
		{"Branch name with slash", "feature/new-ui", false}, // Common git branch pattern - doesn't exist as file
		{"Branch name with slash and numbers", "releases/v1.0", false},
		{"Nested branch name", "hotfix/urgent/security-fix", false},
		{"Tag version", "v1.2.3", false},
		{"Tag without v", "1.0.0", false},
		{"SHA commit", "907ef6a8bc38f144f041e888109ed301dc3d8aaa", false},
		{"Short SHA", "907ef6a", false},
		{"Branch with numbers", "release-2023", false},
		{"Simple word", "production", false},

		// Edge cases
		{"Empty string", "", false},
		{"Just @", "@", false},
		{"Just :", ":", false},
		{"Just /", "/", true}, // Absolute path
		{"Email address", "user@example.com", false}, // Has @ but no : after @
		{"Version tag starting with v", "v2.1.0", false},
		{"Domain-like", "example.com", false}, // More likely a git ref
		
		// SSH edge cases
		{"SSH with port", "git@github.com:22:user/repo.git", true},
		{"SSH-like missing colon after @", "git@github.com", false},
		{"SSH-like with spaces", "git@host: path with spaces", false},
		
		// Path-like edge cases  
		{"Relative path no dots", "projects/myrepo", false}, // Should be branch if doesn't exist
		{"Path starting with v", "v1.0/something", false}, // Excluded from relative path logic
		{"Just a dot", ".", false},
		{"Just two dots", "..", false},
		{"Three dots", "...", false},
		
		// Boundary cases
		{"Very long path", strings.Repeat("a", 200) + "/path", false}, // Long branch name
		{"Path with special chars", "feature/issue-#123", false}, // Branch with special chars
		{"Unicode in path", "功能/新界面", false}, // Unicode branch name
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := IsURL(tt.input)
			assert.Equal(t, tt.expected, result, "Input: %s", tt.input)
		})
	}
}
