#!/bin/bash
set -e

SKILLS_DIR="$HOME/.claude/skills"
SKILLS=(FSD-review)

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FORCE=false
UNINSTALL=false

parse_args() {
  for arg in "$@"; do
    case "$arg" in
      -f|--force)
        FORCE=true
        ;;
      --uninstall)
        UNINSTALL=true
        ;;
      -h|--help)
        echo "Usage: ./install.sh [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  -f, --force      Overwrite existing skills without confirmation"
        echo "  --uninstall      Remove installed skills"
        echo "  -h, --help       Show this help message"
        echo ""
        echo "After installation, use in Claude Code:"
        echo "  /FSD-review   Run FSD frontend code review"
        exit 0
        ;;
      *)
        echo -e "${RED}Unknown option: $arg${NC}"
        echo "Run ./install.sh --help for usage."
        exit 1
        ;;
    esac
  done
}

uninstall_skills() {
  echo -e "${YELLOW}Uninstalling FSD-review skills...${NC}"
  for skill in "${SKILLS[@]}"; do
    target="$SKILLS_DIR/$skill"
    if [ -d "$target" ]; then
      rm -rf "$target"
      echo -e "${GREEN}  Removed: $target${NC}"
    else
      echo -e "${YELLOW}  Not found (skipped): $target${NC}"
    fi
  done
  echo ""
  echo -e "${GREEN}Uninstall complete.${NC}"
}

install_skills() {
  if [ ! -d "$SKILLS_DIR" ]; then
    echo -e "${YELLOW}Creating $SKILLS_DIR ...${NC}"
    mkdir -p "$SKILLS_DIR"
  fi

  echo -e "${YELLOW}Installing FSD-review to $SKILLS_DIR ...${NC}"
  echo ""

  INSTALLED=()
  SKIPPED=()

  for skill in "${SKILLS[@]}"; do
    src="$SCRIPT_DIR/skills/$skill"
    target="$SKILLS_DIR/$skill"

    if [ ! -d "$src" ]; then
      echo -e "${RED}  Warning: source directory not found: $src (skipping)${NC}"
      continue
    fi

    if [ -d "$target" ] && [ "$FORCE" = false ]; then
      echo -e "${YELLOW}  Skill '$skill' already exists at $target${NC}"
      read -r -p "  Overwrite? [y/N] " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        cp -rf "$src" "$SKILLS_DIR/"
        INSTALLED+=("$skill")
        echo -e "${GREEN}  Overwritten: $target${NC}"
      else
        SKIPPED+=("$skill")
        echo -e "${YELLOW}  Skipped: $skill${NC}"
      fi
    else
      cp -rf "$src" "$SKILLS_DIR/"
      INSTALLED+=("$skill")
      echo -e "${GREEN}  Installed: $target${NC}"
    fi
  done

  echo ""

  if [ ${#INSTALLED[@]} -gt 0 ]; then
    echo -e "${GREEN}Installed:${NC}"
    for skill in "${INSTALLED[@]}"; do
      echo -e "${GREEN}  ✓ $skill${NC}"
    done
  fi

  if [ ${#SKIPPED[@]} -gt 0 ]; then
    echo -e "${YELLOW}Skipped:${NC}"
    for skill in "${SKIPPED[@]}"; do
      echo -e "${YELLOW}  - $skill${NC}"
    done
  fi

  echo ""
  echo -e "${GREEN}Installation complete!${NC}"
  echo ""
  echo "Use in Claude Code:"
  echo "  /FSD-review          Run full review (7 stages)"
  echo "  /FSD-review --only ci,security   Run specific stages"
  echo "  /FSD-review --skip test          Skip specific stages"
}

parse_args "$@"

if [ "$UNINSTALL" = true ]; then
  uninstall_skills
else
  install_skills
fi
