# Month 6: Package Management & Development Environment

## Learning Objectives
- Master language-specific package managers (pip, npm, gem)
- Configure isolated development environments
- Understand dependency management best practices
- Set up reproducible project configurations
- Create standardized project structures for different languages

## Resources
- **Primary References**: 
  - Python: [Python Packaging User Guide](https://packaging.python.org/guides/)
  - Node.js: [npm Documentation](https://docs.npmjs.com/)
  - Ruby: [RubyGems Guides](https://guides.rubygems.org/)
- **Language Workflows**: `docs/python-workflow.md`, `docs/javascript-workflow.md`, `docs/ruby-workflow.md`
- **Configuration Templates**: Templates in `configs/` directory

## Week 1: Python Environment Management

### Daily Practice (20-30 minutes)
- Create and activate Python virtual environments
- Install and manage packages with pip and poetry
- Use pyproject to create standardized Python projects

### Assignments
1. **Python Virtual Environments**:
   - Read `docs/python-workflow.md` sections on environment management
   - Master venv creation and activation
   - Learn environment isolation principles
   
2. **Pip Package Management**:
   - Understand pip install, upgrade, and uninstall
   - Learn requirements.txt format and usage
   - Practice installing packages in virtual environments
   
3. **Poetry Advanced Usage**:
   - Configure Poetry for dependency management
   - Understand pyproject.toml structure
   - Learn dependency groups and version constraints
   
4. **Python Project Structure**:
   - Study the Python project template in `scripts/setup/python-setup.sh`
   - Create project structures with proper packaging
   - Configure development tools (pytest, black, mypy)

### Week 1 Project
**Python Environment Template**: Create a customized Python project template with standardized structure, development tools, and documentation.

## Week 2: Node.js/JavaScript Package Management

### Daily Practice (20-30 minutes)
- Create Node.js projects with npm
- Manage dependencies and scripts
- Use nodeproject to create standardized JavaScript projects

### Assignments
1. **NPM Fundamentals**:
   - Read `docs/javascript-workflow.md` sections on package management
   - Understand package.json structure
   - Learn npm commands and workflows
   
2. **Dependency Management**:
   - Master dependencies vs. devDependencies
   - Understand version constraints and semver
   - Practice updating and auditing packages
   
3. **NPM Scripts**:
   - Configure package.json scripts
   - Learn script hooks and composition
   - Create development workflow automation
   
4. **JavaScript Project Structure**:
   - Study the Node.js project template in `scripts/setup/node-setup.sh`
   - Configure ESLint and Prettier
   - Set up testing frameworks (Jest)

### Week 2 Project
**Node.js Project Template**: Create a customized Node.js/JavaScript project template with standardized structure, linting, and testing configuration.

## Week 3: Ruby Environment Management

### Daily Practice (20-30 minutes)
- Set up Ruby environments with RVM/rbenv
- Manage gems and dependencies with Bundler
- Use rubyproject to create standardized Ruby projects

### Assignments
1. **Ruby Version Management**:
   - Read `docs/ruby-workflow.md` sections on environment management
   - Learn RVM/rbenv commands
   - Practice switching between Ruby versions
   
2. **RubyGems Basics**:
   - Understand gem installation and management
   - Learn gemspec format and structure
   - Practice creating and publishing gems
   
3. **Bundler for Dependency Management**:
   - Master Gemfile structure and constraints
   - Learn bundle commands and workflow
   - Understand gem groups and environments
   
4. **Ruby Project Structure**:
   - Study the Ruby project template in `scripts/setup/ruby-setup.sh`
   - Configure RSpec and Rubocop
   - Set up proper project organization

### Week 3 Project
**Ruby Project Template**: Create a customized Ruby project template with standardized structure, testing, and linting configuration.

## Week 4: Docker Development Environments

### Daily Practice (20-30 minutes)
- Build and run Docker containers
- Create Docker Compose configurations
- Practice developing inside containers

### Assignments
1. **Docker Basics**:
   - Understand Docker concepts and workflow
   - Study the Dockerfile templates in `configs/docker/templates/`
   - Learn container lifecycle management
   
2. **Dockerfile Creation**:
   - Create language-specific Dockerfiles
   - Optimize image size and build time
   - Implement multi-stage builds
   
3. **Docker Compose**:
   - Configure multi-container applications
   - Define service dependencies
   - Manage volumes and networking
   
4. **Container Development Workflow**:
   - Set up editor integration with containers
   - Configure debugging in containers
   - Implement efficient rebuild strategies

### Week 4 Project
**Containerized Development Environment**: Create a Docker-based development environment for a multi-service application, with proper configuration for local development.

## Month 6 Project: Complete Development Environment

**Objective**: Create a standardized, reproducible development environment setup for multi-language projects.

**Requirements**:
1. Language-specific environment configuration for Python, Node.js, and Ruby
2. Docker-based development setup with docker-compose.yml
3. Standardized project templates for each language
4. Automated setup scripts for new developers
5. Documentation of the complete environment

**Deliverables**:
- Collection of project templates for each language
- Docker configuration for local development
- Environment setup scripts
- Package management guide for each language
- Development workflow documentation

## Assessment Criteria
- Environment reproducibility and isolation
- Project template quality and standards
- Docker configuration efficiency
- Documentation comprehensiveness
- Setup automation reliability

## Suggested Daily Routine
1. 10 minutes reviewing package management concepts
2. 15 minutes practicing environment setup
3. 20-30 minutes working with dependencies and configurations
4. 5 minutes documenting best practices and lessons learned
