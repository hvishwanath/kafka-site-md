# GitHub Actions Workflows

## Build and Deploy Workflow

The `build-and-deploy.yml` workflow automatically builds the site using `make build` and deploys the HTML output to the `site-html` branch.

### Configuration

#### Configurable Branches
You can configure which branches trigger the build in two ways:

1. **Repository Variables** (Recommended):
   - Go to your repository Settings → Secrets and variables → Actions → Variables
   - Add a new variable named `BUILD_BRANCHES`
   - Set the value to comma-separated branch names (e.g., `markdown,main,develop`)

2. **Manual Workflow Dispatch**:
   - Go to Actions tab → Build and Deploy Site → Run workflow
   - Specify target branches in the input field

#### Default Behavior
- If no `BUILD_BRANCHES` variable is set, the workflow defaults to `markdown,main`
- The workflow triggers on push to configured branches
- Manual dispatch is always available

### How It Works

1. **Build Process**:
   - Checks out the repository
   - Sets up Docker Buildx for multi-platform builds
   - Builds the Hugo Docker image locally
   - Runs `make build` to generate the site
   - Verifies the build output

2. **Deployment Process**:
   - Creates or checks out the `site-html` branch
   - Copies all HTML files from the `output/` directory to the branch root
   - Commits and pushes changes to the `site-html` branch

### Output

The `site-html` branch will contain:
- All generated HTML files
- Static assets (CSS, JS, images)
- Site structure matching the Hugo output

### Docker Setup

The workflow handles Docker setup automatically:
- Uses the existing Dockerfile to build the Hugo image
- No external Docker registry required
- Builds the image locally in the GitHub Actions runner

### Troubleshooting

If the workflow fails:
1. Check the build logs for Docker build errors
2. Verify the `make build` command completes successfully
3. Ensure the `output/` directory contains HTML files
4. Check Git permissions for pushing to `site-html` branch
