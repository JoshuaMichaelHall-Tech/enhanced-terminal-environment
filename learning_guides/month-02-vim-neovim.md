# Month 2: Vim, Neovim & Text Editing

## Learning Objectives
- Master Vim/Neovim fundamentals for efficient text editing
- Develop muscle memory for common editing operations
- Learn to navigate and manipulate text with minimal keystrokes
- Understand Vim's modal editing philosophy
- Customize Neovim for your specific needs

## Resources
- **Primary Text**: [Learn Vim (the Smart Way)](https://github.com/iggredible/Learn-Vim) (Chapters 1-12)
- **Daily Practice**: `vimtutor` (run this command in your terminal)
- **Reference**: Your configured `init.lua` at `~/.config/nvim/init.lua`
- **Supplementary**: [Practical Vim](https://pragprog.com/titles/dnvim2/practical-vim-second-edition/) by Drew Neil (optional purchase)

## Week 1: Vim Fundamentals & Navigation

### Daily Practice (20-30 minutes)
- Complete one lesson in `vimtutor` (run daily for the first week)
- Practice mode switching (normal, insert, visual, command)
- Learn 3-5 new commands or motions each day
- Keep a Vim commands journal - document new commands with examples

### Assignments
1. **Understanding Modes**:
   - Read Learn Vim Chapters 1-2
   - Practice switching between normal, insert, visual, and command modes
   - Complete first half of `vimtutor` lessons
   
2. **Basic Navigation**:
   - Master basic motions: `h`, `j`, `k`, `l`, `w`, `b`, `e`, `0`, `$`, `^`
   - Practice jumping with `f`, `F`, `t`, `T`
   - Navigate by paragraphs with `{` and `}`
   
3. **Editing Fundamentals**:
   - Learn basic editing commands: `i`, `a`, `o`, `O`, `c`, `d`, `y`, `p`
   - Practice deleting words and lines with `dw`, `dd`
   - Understand operators and text objects concept
   
4. **First Vim Configuration**:
   - Review your Neovim configuration in `~/.config/nvim/init.lua`
   - Understand basic settings and mappings
   - Make a minor customization (e.g., changing a color setting)

### Week 1 Project
**Vim Config Documentation**: Document your current Neovim configuration, explaining each setting and keybinding in your own words to reinforce understanding.

## Week 2: Text Objects & Advanced Editing

### Daily Practice (20-30 minutes)
- Practice combining verbs, modifiers, and text objects
- Edit an existing file using only Vim commands (no arrow keys!)
- Time yourself on editing tasks, aiming to improve speed daily

### Assignments
1. **Text Objects Mastery**:
   - Read Learn Vim Chapters 3-4
   - Practice with text objects: `w`, `s`, `p`, `(`, `{`, `[`, `'`, `"`
   - Complete exercises combining operators with text objects
   
2. **Advanced Editing**:
   - Learn advanced editing commands: `c`, `C`, `s`, `S`, `r`, `R`
   - Practice changing text inside text objects (`ciw`, `ci"`, `ci(`)
   - Understand the dot `.` command for repeating actions
   
3. **Visual Mode**:
   - Master visual mode selection: character, line, and block
   - Edit multiple lines at once with visual block mode
   - Practice visual mode operations with text objects
   
4. **Search and Replace**:
   - Learn search navigation with `/` and `?`
   - Practice search patterns and understanding basic regex
   - Use substitute command for search and replace (`:%s/old/new/g`)

### Week 2 Project
**Text Transformation Tool**: Create a script that takes a text file and performs various transformations using Vim commands in Ex mode.

## Week 3: Advanced Navigation & Workflow

### Daily Practice (20-30 minutes)
- Navigate between multiple files without using the mouse
- Practice split window navigation and management
- Use marks to jump between locations in files

### Assignments
1. **Efficient Navigation**:
   - Read Learn Vim Chapters 5-8
   - Practice jumping with `gg`, `G`, `:line_number`
   - Learn to use `Ctrl-o` and `Ctrl-i` for jump list navigation
   
2. **Marks and Jumps**:
   - Set and use marks with `m{a-zA-Z}` and `'{a-zA-Z}`
   - Understand local vs. global marks
   - Practice navigating between frequently used locations
   
3. **Window Management**:
   - Master split windows with `<leader>sv` and `<leader>sh`
   - Navigate between splits using `<C-h/j/k/l>`
   - Resize and reorganize splits
   
4. **Buffer Management**:
   - Understand buffers vs. windows vs. tabs
   - Practice buffer commands: `:bn`, `:bp`, `:bd`
   - Use custom keybindings for buffer management

### Week 3 Project
**Multi-file Editing Workflow**: Develop a workflow for editing multiple related files, documenting your approach for navigation, making coordinated changes, and maintaining context.

## Week 4: Customization & Language Support

### Daily Practice (20-30 minutes)
- Try one new plugin or feature each day
- Practice editing files in languages you commonly use
- Refine your custom keybindings based on daily usage

### Assignments
1. **Neovim Customization**:
   - Read Learn Vim Chapters 9-12
   - Explore the commented-out plugin section in your `init.lua`
   - Learn to add basic settings and keymappings
   
2. **Language-Specific Settings**:
   - Study language-specific configurations in `~/.config/nvim/lua/language-specific/`
   - Understand how different languages are configured differently
   - Set up specific settings for a language you use
   
3. **File Navigation Plugins**:
   - Uncomment and explore the file explorer section in your config
   - Learn to use fuzzy finding for file navigation
   - Practice telescope.nvim basics if enabled
   
4. **Git Integration**:
   - Learn Vim/Neovim Git workflows
   - Practice using git commands from within Neovim
   - Explore Git plugins like gitsigns.nvim if available

### Week 4 Project
**Personal Neovim Configuration**: Create a personalized Neovim configuration focused on your specific development needs, with custom keybindings, settings, and potentially a few carefully chosen plugins.

## Month 2 Project: Complete Text Editor Workflow

**Objective**: Develop a comprehensive text editing workflow with Neovim that significantly improves your productivity.

**Requirements**:
1. A customized Neovim configuration that enhances your specific workflows
2. Documentation of at least 50 commands/mappings you've mastered with examples
3. A set of custom keybindings that improve your efficiency
4. A demonstration of your editing workflow on a non-trivial coding task
5. Benchmarks comparing your editing speed before and after training

**Deliverables**:
- Your customized `init.lua` with clear comments
- Vim command cheatsheet with your most-used commands
- Recorded demonstration of your editing workflow
- Written reflection on your progress and areas for improvement

## Assessment Criteria
- Command fluency and accuracy
- Editing efficiency (measured by time or keystrokes)
- Configuration quality and organization
- Workflow demonstration clarity
- Evidence of improved productivity

## Suggested Daily Routine
1. 10 minutes of targeted practice on specific commands
2. 10 minutes reading documentation or tutorials
3. 10-30 minutes applying Vim in real editing tasks
4. 5 minutes reflecting on what's working and what needs improvement
