#!/usr/bin/env bash
set -e

echo "Welcome to the aer-plugin setup!"

# 1- Project name should start with aer-
read -p "Enter your project name (e.g., aer-search-earthaccess): " PROJECT_NAME
if [[ ! $PROJECT_NAME =~ ^aer- ]]; then
    echo "Error: Project name must start with 'aer-'"
    exit 1
fi

read -p "Enter Author Name: " AUTHOR_NAME
if [ -z "$AUTHOR_NAME" ]; then
    echo "Author Name cannot be empty."
    exit 1
fi

read -p "Enter GitHub username/organization: " GITHUB_ORG
if [ -z "$GITHUB_ORG" ]; then
    echo "GitHub username/organization cannot be empty."
    exit 1
fi

echo "Setting up project: $PROJECT_NAME..."

# Basic variables
PLUGIN_PART=${PROJECT_NAME/aer-/}
COMPONENT_NAME=$(echo "$PLUGIN_PART" | tr '-' '_')

# Update root pyproject.toml name (ignoring previous user change if I need to be exact, but user changed it to include "-workspace" so let's keep that pattern)
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^name = .*/name = \"$PROJECT_NAME-workspace\"/" pyproject.toml
else
    sed -i "s/^name = .*/name = \"$PROJECT_NAME-workspace\"/" pyproject.toml
fi


# Install uv if missing
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
else
    echo "uv is already installed."
fi

# Add polylith-cli as a dev dependency and sync
echo "Adding dev dependencies..."
uv add polylith-cli python-semantic-release pytest --dev
uv sync

# 2- Create component and project
echo "Creating component: $COMPONENT_NAME..."
uv run poly create component --name "$COMPONENT_NAME"

echo "Creating project: $PROJECT_NAME..."
uv run poly create project --name "$PROJECT_NAME"

# 3- Add corresponding plugin entrypoint to the created project pyproject.toml
PROJECT_PYPROJECT="projects/$PROJECT_NAME/pyproject.toml"

echo "Customizing $PROJECT_PYPROJECT..."

cat <<EOF > "$PROJECT_PYPROJECT"
[build-system]
requires = ["hatchling", "hatch-polylith-bricks"]
build-backend = "hatchling.build"

[project]
name = "$PROJECT_NAME"
version = "0.1.0"
description = "Polylith project for the $PLUGIN_PART plugin"
readme = "README.md"
authors = [{ name = "$AUTHOR_NAME" }]

requires-python = ">=3.13"

dependencies = [
    "aer-core,
]

[project.urls]
Homepage = "https://github.com/$GITHUB_ORG/$PROJECT_NAME"
Issues = "https://github.com/$GITHUB_ORG/$PROJECT_NAME/issues"
Repository = "https://github.com/$GITHUB_ORG/$PROJECT_NAME"

[project.entry-points."aer.plugins"]
$COMPONENT_NAME = "aer.$COMPONENT_NAME.core:$COMPONENT_NAME"

[tool.hatch]
build.hooks.polylith-bricks = {}
build.targets.wheel.packages = ["aer"]

[tool.polylith]
bricks."../../components/aer/$COMPONENT_NAME" = "aer/$COMPONENT_NAME"
EOF

# Install prek tool
echo "Installing prek..."
uv tool install prek || true

echo "--------------------------------------------------------"
echo "Setup complete! Project $PROJECT_NAME is ready."
echo "Created component: components/aer/$COMPONENT_NAME"
echo "Created project: projects/$PROJECT_NAME"
echo "--------------------------------------------------------"

