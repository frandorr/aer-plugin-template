# Python Polylith Template with `uv`

A minimal template repository for aer plugins using the [Polylith architecture](https://davidvujic.github.io/python-polylith-docs/setup/), powered by `uv` for lightning-fast dependency management, and `prek` for git hooks.

### Creating Plugins (aer)

In `aer`, plugins typically consist of a component (for the logic) and a project (for packaging). You can use the Polylith CLI to create these.

**Important Rules**:
- **Prefix**: Plugin projects must use the `aer-` prefix (e.g., `aer-search-myprovider`) to be easily discoverable and identifiable within the ecosystem.
- **Versioning**: Plugins should use [Semantic Versioning](https://semver.org/) (SemVer) for their releases.

**Example: Creating a Search Plugin**
```bash
uv run poly create component --name search_myprovider
uv run poly create project --name aer-search-myprovider
```

After implementing your logic (e.g., `search_myprovider(request: SearchRequest) -> SearchResult`), register the plugin in the project's `pyproject.toml` so `aer-core` can discover it:
```toml
[project.entry-points."aer.plugins"]
myprovider = "aer.search_myprovider.core:search_myprovider"
```

**Example: Creating a Spectral Plugin**
```bash
uv run poly create component --name spectral_myinstrument
uv run poly create project --name aer-spectral-myinstrument
```

Register the spectral plugin in its `pyproject.toml` similarly:
```toml
[project.entry-points."aer.plugins"]
myinstrument = "aer.spectral_myinstrument.core:spectral_myinstrument"
```

### Inspecting the Workspace

Polylith shines at giving you an overview of your monorepo. Check your projects, bases, and components with:

```bash
uv run poly info
```

---

## Development Workflow

1. **Install dependencies:**  
   If you need to manually sync your environment or add third-party dependencies, use `uv`:
   ```bash
   uv sync
   uv add requests
   uv add --group dev pytest
   ```

2. **Run tests:**  
   You can run your tests across the entire workspace easily using `pytest`. The template enables tests globally across components:
   ```bash
   uv run pytest
   ```

3. **Hooks (prek):**  
   We use `prek` for streamlined commit checks. The setup script installs it globally via `uv tool install prek`. You can use it to configure git workflows without heavy external dependencies.

---

## Releasing Plugins

Releases are managed using [Conventional Commits](https://www.conventionalcommits.org/) and `python-semantic-release`. A helper script is provided in `.agents/scripts/release.py`.

### Automated Versioning

The `release.py` script analyzes your commit history since the last tag to determine the next version (patch, minor, or major).

1.  **Commit your changes** using conventional prefixes (e.g., `feat:`, `fix:`, `chore:`).
2.  **Run the release script**:
    ```bash
    # Release a specific project
    python3 .agents/scripts/release.py aer-search-myprovider

    # Release all projects with pending changes
    python3 .agents/scripts/release.py --changed
    ```

The script will:
- Update the version in `projects/<project>/pyproject.toml`.
- Create a release commit and a git tag (e.g., `aer-search-myprovider-v1.0.1`).
- Push the tag to `origin`.

### AI Assistant (Antigravity/Agentic)

If you are using an AI assistant like Antigravity, you can simply ask:
> "Release aer-search-myprovider"

It will use the `new-release` skill to execute the workflow automatically.


---

## License

MIT