# Terraform Graph

## What is Terraform Graph?

The `terraform graph` command generates a visual representation of your Terraform configuration's resource dependencies. It outputs the graph in DOT format (GraphViz), showing how resources relate to and depend on each other.

**Use cases:**
- Understand resource dependencies
- Troubleshoot dependency issues
- Document infrastructure architecture
- Visualize complex configurations

---

## Generating and Viewing the Graph

> Note: Make sure you are working in the `instances` directory.

### Step 1: Generate the Graph

From your Terraform configuration directory:
```bash
terraform graph | dot -Tpng > graph.png
```

**What this does:**
- `terraform graph` - Generates DOT format output
- `dot -Tpng` - Converts DOT to PNG image
- `> graph.png` - Saves to file

**Note:** Requires `graphviz` package installed:
```bash
# Debian/Ubuntu
sudo apt install graphviz

# macOS
brew install graphviz
```

### Step 2: View the Graph

You can view these directly in VS Code, or:

**Open with Firefox:**
```bash
firefox graph.png
# or
firefox-esr graph.png
```

**Or use your default image viewer:**
```bash
xdg-open graph.png        # Linux
open graph.png            # macOS
start graph.png           # Windows
```

---

## Alternative Output Formats
```bash
# SVG (scalable vector)
terraform graph | dot -Tsvg > graph.svg

# PDF
terraform graph | dot -Tpdf > graph.pdf

# View directly in terminal (requires graphviz-x)
terraform graph | dot -Tx11
```

---

## Online Visualization Tools

You can paste the raw DOT output into online visualizers:

**Example: WebGraphviz**
1. Run: `terraform graph > graph.dot`
2. Copy the contents of `graph.dot`
3. Go to: http://webgraphviz.com
4. Paste and visualize

**⚠️ SECURITY WARNING:**
- Online tools may store or log your graph data
- Your graph reveals your infrastructure architecture
- Resource names, dependencies, and configuration structure are exposed
- **DO NOT** use online tools for production or sensitive infrastructure. I HAVE SPOKEN!
- Only use for learning/development with non-sensitive configs

---

## Understanding the Graph

**Node types:**
- **Resources** - Purple boxes (e.g., `aws_instance.web_server_1`)
- **Variables** - Green boxes (e.g., `var.instance_type`)
- **Outputs** - Yellow boxes (e.g., `output.public_ip`)
- **Provider** - Orange boxes (e.g., `provider[aws]`)

**Arrows:** Show dependencies (A → B means "A depends on B")

---

## Tips

- Run `terraform graph` AFTER `terraform init` or `terraform apply` to see provider dependencies.
- Larger configurations create complex graphs - zoom in!
- Use SVG format for better quality when zooming.
- Save graphs to document your infrastructure over time.