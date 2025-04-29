#!/bin/bash
# Ruby development environment setup script
# Part of Enhanced Terminal Environment - Updated for OS detection

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
    echo -e "${BLUE}Detected macOS system${NC}"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
    echo -e "${BLUE}Detected Linux system${NC}"
else
    echo -e "${RED}Unsupported operating system: $OSTYPE${NC}"
    exit 1
fi

echo -e "${BLUE}Setting up Ruby development environment...${NC}"

# Install RVM (Ruby Version Manager)
if ! command -v rvm &>/dev/null; then
    echo -e "${BLUE}Installing RVM (Ruby Version Manager)...${NC}"
    
    # Install GPG keys
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB || {
        echo -e "${YELLOW}Could not receive GPG keys from primary server, trying alternate...${NC}"
        gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    }
    
    # Install RVM
    curl -sSL https://get.rvm.io | bash -s stable
    
    # Add RVM to shell profile if not already there
    if [[ -z $(grep -r "rvm/scripts/rvm" ~/.zshrc) ]]; then
        cat >> ~/.zshrc << 'EOL'

# RVM (Ruby Version Manager)
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
export PATH="$PATH:$HOME/.rvm/bin"
EOL
    fi
    
    # Load RVM for current session
    source "$HOME/.rvm/scripts/rvm"
    
else
    echo -e "${GREEN}RVM already installed.${NC}"
    # Update RVM
    rvm get stable
fi

# Install latest stable Ruby version
echo -e "${BLUE}Installing latest stable Ruby version...${NC}"
rvm install ruby --latest
rvm use ruby --latest --default

# Install essential Ruby gems
echo -e "${BLUE}Installing essential Ruby development tools...${NC}"
gem install \
    bundler \
    pry \
    rubocop \
    solargraph \
    rspec \
    rake

# Create standard Ruby project template directory
TEMPLATE_DIR="$HOME/.local/share/ruby-templates"
mkdir -p "$TEMPLATE_DIR"

# Create a basic Ruby project template
cat > "$TEMPLATE_DIR/basic_ruby_project.sh" << 'EOL'
#!/bin/bash
# Basic Ruby project template generator

if [ "$#" -ne 1 ]; then
    echo "Usage: rubyproject projectname"
    exit 1
fi

PROJECT_NAME="$1"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create project structure
mkdir -p lib
mkdir -p spec
mkdir -p bin

# Create Gemfile
cat > Gemfile << 'EOF'
source 'https://rubygems.org'

group :development, :test do
  gem 'rspec', '~> 3.10'
  gem 'rubocop', '~> 1.20'
  gem 'solargraph', '~> 0.44'
  gem 'pry', '~> 0.14'
end
EOF

# Create main library file
cat > lib/${PROJECT_NAME}.rb << EOF
# Main module for ${PROJECT_NAME}
module ${PROJECT_NAME^}
  VERSION = '0.1.0'.freeze

  # Your code goes here...
end
EOF

# Create executable
cat > bin/${PROJECT_NAME} << 'EOF'
#!/usr/bin/env ruby

require_relative '../lib/PROJECT_NAME'

# Add command-line handling code here
puts "Hello from PROJECT_NAME!"
EOF
sed -i "s/PROJECT_NAME/${PROJECT_NAME}/g" bin/${PROJECT_NAME}
chmod +x bin/${PROJECT_NAME}

# Create spec file
cat > spec/${PROJECT_NAME}_spec.rb << EOF
require '${PROJECT_NAME}'

RSpec.describe ${PROJECT_NAME^} do
  it 'has a version number' do
    expect(${PROJECT_NAME^}::VERSION).not_to be nil
  end
  
  it 'does something useful' do
    expect(true).to eq(true)
  end
end
EOF

# Create spec helper
cat > spec/spec_helper.rb << 'EOF'
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end
EOF

# Create Rakefile
cat > Rakefile << 'EOF'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec
EOF

# Create README
cat > README.md << EOF
# ${PROJECT_NAME^}

A Ruby project.

## Installation

\`\`\`bash
# Install dependencies
bundle install
\`\`\`

## Usage

\`\`\`ruby
require '${PROJECT_NAME}'

# Your code here
\`\`\`

## Development

\`\`\`bash
# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop
\`\`\`

## Acknowledgements

This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation writing and organization
- Code structure suggestions
- Troubleshooting and debugging assistance

Claude was used as a development aid while all final implementation decisions and code review were performed by Joshua Michael Hall.

## Disclaimer

This software is provided "as is", without warranty of any kind, express or implied. The authors or copyright holders shall not be liable for any claim, damages or other liability arising from the use of the software.

This project is a work in progress and may contain bugs or incomplete features. Users are encouraged to report any issues they encounter.
EOF

# Create essential configuration files
cat > .gitignore << 'EOF'
# Ruby specific
*.gem
*.rbc
/.config
/coverage/
/InstalledFiles
/pkg/
/spec/reports/
/spec/examples.txt
/test/tmp/
/test/version_tmp/
/tmp/

# Environment normalization
/.bundle/
/vendor/bundle
/lib/bundler/man/

# RVM
.rvmrc

# IDE specific files
.idea/
.vscode/
*.swp
*.swo

# OS specific files
.DS_Store
Thumbs.db
EOF

# Create .rubocop.yml
cat > .rubocop.yml << 'EOF'
AllCops:
  NewCops: enable
  TargetRubyVersion: 3.0

Style/StringLiterals:
  Enabled: true
  EnforcedStyle: single_quotes

Style/Documentation:
  Enabled: false

Layout/LineLength:
  Max: 100

Metrics/MethodLength:
  Max: 15

Metrics/BlockLength:
  Exclude:
    - 'spec/**/*'
EOF

# Initialize bundle
bundle init
bundle install

# Initialize Git repository
git init

echo "Ruby project ${PROJECT_NAME^} created successfully!"
EOL

# Make template executable
chmod +x "$TEMPLATE_DIR/basic_ruby_project.sh"

# Create rubyproject function
if [[ -z $(grep -r "rubyproject()" ~/.zshrc) ]]; then
    cat >> ~/.zshrc << 'EOL'

# Ruby project creator function
rubyproject() {
    $HOME/.local/share/ruby-templates/basic_ruby_project.sh "$@"
}
EOL
fi

echo -e "${GREEN}Ruby environment setup complete!${NC}"
echo -e "${YELLOW}Restart your shell or run 'source ~/.zshrc' to use the new commands${NC}"
