 Multiple filters are AND'ed together by default. When you specify multiple qualifiers like author:me assignee:me, it searches for items that match ALL conditions.

  Key syntax elements:

  1. Colon operators (:) - filter by specific attributes:
    - author:USERNAME - created by user
    - assignee:USERNAME - assigned to user
    - is:issue or is:pr - type filters
    - state:open or state:closed - state filters
  2. Special username values:
    - @me - refers to the current logged-in user
    - Regular usernames without @
  3. Exclusion with - (minus):
    - -assignee:me - NOT assigned to me
    - -label:bug - NOT labeled as bug
  4. The NOT operator - excludes keywords:
    - hello NOT world - contains "hello" but not "world"

  Examples:
  - author:me assignee:me - issues/PRs you created AND are assigned to
  - author:me -assignee:me - you created but NOT assigned to you
  - involves:@me - you're mentioned, assigned, authored, or commented (this is an OR condition built into the involves qualifier)

  So yes, when you use multiple qualifiers, they create an AND condition - all must be true for a match.

> and to target body/title/any with string in search?

● Based on the GitHub search syntax, here's how to target specific fields with strings:

  For issues/PRs, use the in: qualifier:

  :Octo search "error message" in:title
  :Octo search "error message" in:body
  :Octo search "error message" in:comments

  Multiple fields (OR condition within in:):
  :Octo search "error message" in:title,body
  :Octo search "error message" in:title,body,comments

  Default behavior (no in: qualifier):
  :Octo search "error message"
  This searches in title, body, AND comments by default.

  Examples:
  - :Octo search "bug fix" in:title is:pr - PRs with "bug fix" in title only
  - :Octo search "TODO" in:body author:me - your issues/PRs with "TODO" in body
  - :Octo search "breaking change" in:title,body - "breaking change" in title OR body

  Note: Use quotes for multi-word phrases:
  - :Octo search "breaking change" - exact phrase
  - :Octo search breaking change - items containing both words (not necessarily together)

  The in: qualifier is specifically for targeting where the text appears in the issue/PR.

## How Octo Search Works Internally

When you run `Octo search is:pr involves:@me`, here's what happens:

1. **Command Processing** (`commands.lua`):
   ```lua
   function M.search(...)
     local args = table.pack(...)
     local prompt = table.concat(args, " ")  -- "is:pr involves:@me"
     
     local type = "ISSUE"  -- default
     picker.search { prompt = prompt, type = type }
   end
   ```

2. **Picker Processing** (`provider.lua`):
   ```lua
   function M.search(opts)
     opts.type = opts.type or "ISSUE"  -- Still "ISSUE" 
     -- opts.prompt = ["is:pr involves:@me"]
     
     for _, val in ipairs(opts.prompt) do
       local output = gh.api.graphql {
         query = queries.search,
         fields = { prompt = val, type = opts.type },  -- GraphQL variables
       }
     end
   end
   ```

3. **GraphQL Query** (`queries.lua`):
   ```graphql
   query($prompt: String!, $type: SearchType = ISSUE, $last: Int = 100) {
     search(query: $prompt, type: $type, last: $last) {
       nodes {
         ... on Issue { __typename number url title state repository { nameWithOwner } }
         ... on PullRequest { __typename number title url state isDraft repository { nameWithOwner } }
         ... on Discussion { __typename number title url repository { nameWithOwner } }
       }
     }
   }
   ```

**Key Insight**: The `type: ISSUE` parameter is misleading! GitHub's GraphQL `search` query with `type: ISSUE` actually searches **both Issues AND Pull Requests** when the search string contains `is:pr`. The search string `"is:pr involves:@me"` is passed directly to GitHub's search API, which handles the `is:pr` filter internally.

**Difference between `Octo search` vs `Octo issue search`**:
- `Octo search` - Global search across all repositories using GitHub's search API
- `Octo issue search` - Auto-detects current repository and scopes search to that repo only

## Investigation Tasks

### TODO: Analyze GitHub Issue Status Fields

Investigate what the "status" field represents in GitHub issues and how to query it:

**Questions to research:**
1. What is the `status` field in GitHub issues? (vs `state` which is open/closed)
2. Is `status:inProgress` a valid search qualifier?
3. How does it relate to GitHub Projects v2 status fields?
4. What are the possible status values?
5. Can we use it in Octo search queries like: `Octo search issue status:inProgress`

**Research approach:**
- Check GitHub GraphQL schema documentation
- Look at GitHub search API documentation  
- Test different status values in GitHub web search
- Check if Octo's GraphQL queries include status fields
- Investigate GitHub Projects integration
