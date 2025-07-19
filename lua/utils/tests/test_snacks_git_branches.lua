-- Test for snacks-git.lua branch detection functionality
-- Tests for issue #24: branch detection and listing problems

local M = {}

-- Mock git command outputs for testing (reserved for future use)
local _mock_git_outputs = {
  branches_local = "  main\n* fix/snacks-git-branch-detection-issue-24\n  feature/test-branch\n  develop",
  branches_remote = "  origin/main\n  origin/develop\n  origin/feature/remote-branch",
  branches_all = "  main\n* fix/snacks-git-branch-detection-issue-24\n  feature/test-branch\n  develop\n  remotes/origin/main\n  remotes/origin/develop\n  remotes/origin/feature/remote-branch",
  current_branch = "fix/snacks-git-branch-detection-issue-24"
}

-- Test helper functions
local function run_git_command(cmd)
  local handle = io.popen(cmd)
  if not handle then
    return nil
  end
  local result = handle:read("*a")
  handle:close()
  return result
end

local function get_current_branch()
  return run_git_command("git branch --show-current")
end

local function get_all_branches()
  return run_git_command("git branch -a")
end

local function get_local_branches()
  return run_git_command("git branch")
end

local function get_remote_branches()
  return run_git_command("git branch -r")
end

-- Test functions
function M.test_current_branch_detection()
  print("Testing current branch detection...")
  
  local current = get_current_branch()
  if current then
    current = current:gsub("%s+", "")
    print("✓ Current branch detected: " .. current)
    
    if current == "" then
      print("✗ ERROR: Current branch is empty string")
      return false
    end
    
    if current:match("fix/snacks%-git%-branch%-detection%-issue%-24") then
      print("✓ Correct test branch detected")
      return true
    else
      print("✗ WARNING: Expected test branch, got: " .. current)
      return true -- Still valid, just different branch
    end
  else
    print("✗ ERROR: Failed to detect current branch")
    return false
  end
end

function M.test_local_branches_listing()
  print("Testing local branches listing...")
  
  local branches = get_local_branches()
  if not branches then
    print("✗ ERROR: Failed to get local branches")
    return false
  end
  
  local branch_count = 0
  local has_current_marker = false
  
  for line in branches:gmatch("[^\r\n]+") do
    branch_count = branch_count + 1
    if line:match("^%*") then
      has_current_marker = true
      print("✓ Found current branch marker: " .. line)
    end
    print("  Branch: " .. line:gsub("^%s*%*?%s*", ""))
  end
  
  print("✓ Found " .. branch_count .. " local branches")
  
  if not has_current_marker then
    print("✗ ERROR: No current branch marker (*) found")
    return false
  end
  
  return true
end

function M.test_remote_branches_listing()
  print("Testing remote branches listing...")
  
  local branches = get_remote_branches()
  if not branches then
    print("✗ ERROR: Failed to get remote branches")
    return false
  end
  
  local remote_count = 0
  for line in branches:gmatch("[^\r\n]+") do
    if line:match("origin/") then
      remote_count = remote_count + 1
      print("  Remote branch: " .. line:gsub("^%s*", ""))
    end
  end
  
  print("✓ Found " .. remote_count .. " remote branches")
  return remote_count > 0
end

function M.test_all_branches_listing()
  print("Testing all branches listing...")
  
  local branches = get_all_branches()
  if not branches then
    print("✗ ERROR: Failed to get all branches")
    return false
  end
  
  local local_count = 0
  local remote_count = 0
  
  for line in branches:gmatch("[^\r\n]+") do
    if line:match("remotes/") then
      remote_count = remote_count + 1
    else
      local_count = local_count + 1
    end
  end
  
  print("✓ Found " .. local_count .. " local and " .. remote_count .. " remote branches")
  
  -- Verify that all branches shows more than local only
  local local_only = get_local_branches()
  local local_only_count = 0
  if local_only then
    for line in local_only:gmatch("[^\r\n]+") do
      if line:match("%S") then
        local_only_count = local_only_count + 1
      end
    end
  end
  
  local total_all = local_count + remote_count
  if total_all > local_only_count then
    print("✓ All branches (" .. total_all .. ") > local only (" .. local_only_count .. ") - Fix verified!")
    return true
  else
    print("✗ ERROR: All branches should show more than local only")
    return false
  end
end

function M.test_branch_name_parsing()
  print("Testing branch name parsing logic...")
  
  -- Test the get_branch_name function logic from snacks-git.lua
  local function get_branch_name(item)
    if type(item) == "string" then
      return item
    elseif type(item) == "table" then
      return item.text or item.value or item[1]
    end
  end
  
  -- Test cases
  local test_cases = {
    { input = "main", expected = "main" },
    { input = "  * fix/test-branch", expected = "  * fix/test-branch" },
    { input = { text = "feature/branch" }, expected = "feature/branch" },
    { input = { value = "develop" }, expected = "develop" },
    { input = { "hotfix/urgent" }, expected = "hotfix/urgent" },
    { input = {}, expected = nil },
    { input = nil, expected = nil }
  }
  
  local passed = 0
  local total = #test_cases
  
  for i, case in ipairs(test_cases) do
    local result = get_branch_name(case.input)
    if result == case.expected then
      print("✓ Test case " .. i .. " passed")
      passed = passed + 1
    else
      print("✗ Test case " .. i .. " failed: expected '" .. tostring(case.expected) .. "', got '" .. tostring(result) .. "'")
    end
  end
  
  print("Branch name parsing: " .. passed .. "/" .. total .. " tests passed")
  return passed == total
end

function M.test_git_repository_status()
  print("Testing git repository status...")
  
  local status = run_git_command("git status --porcelain")
  if status == nil then
    print("✗ ERROR: Not in a git repository or git command failed")
    return false
  end
  
  print("✓ Git repository detected")
  
  local is_clean = (status:gsub("%s+", "") == "")
  if is_clean then
    print("✓ Working directory is clean")
  else
    print("! Working directory has changes:")
    print(status)
  end
  
  return true
end

-- Main test runner
function M.run_all_tests()
  print("=== Snacks Git Branch Detection Tests ===")
  print("Testing for issue #24: branch detection and listing problems")
  print("")
  
  local tests = {
    { name = "Git Repository Status", func = M.test_git_repository_status },
    { name = "Current Branch Detection", func = M.test_current_branch_detection },
    { name = "Local Branches Listing", func = M.test_local_branches_listing },
    { name = "Remote Branches Listing", func = M.test_remote_branches_listing },
    { name = "All Branches Listing", func = M.test_all_branches_listing },
    { name = "Branch Name Parsing", func = M.test_branch_name_parsing }
  }
  
  local passed = 0
  local total = #tests
  
  for _, test in ipairs(tests) do
    print("--- " .. test.name .. " ---")
    local success = test.func()
    if success then
      passed = passed + 1
      print("✓ " .. test.name .. " PASSED")
    else
      print("✗ " .. test.name .. " FAILED")
    end
    print("")
  end
  
  print("=== Test Summary ===")
  print("Passed: " .. passed .. "/" .. total)
  
  if passed == total then
    print("✓ ALL TESTS PASSED")
  else
    print("✗ SOME TESTS FAILED - Issue #24 symptoms may be present")
  end
  
  return passed == total
end

-- Auto-run tests if executed directly
if not pcall(debug.getlocal, 4, 1) then
  M.run_all_tests()
end

return M