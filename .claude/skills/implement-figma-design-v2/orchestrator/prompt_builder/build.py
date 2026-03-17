#!/usr/bin/env python3
"""
Prompt template builder for implement-figma-design skill.

Renders prompt templates with placeholder substitution and conditional blocks.
Adapted from trycycle's prompt_builder for Figma design implementation workflows.

Usage:
    python3 build.py --template <path> --set NAME=VALUE --set-file NAME=PATH --output <path>

Placeholder syntax:
    {PLACEHOLDER_NAME}          — replaced with bound value
    {{#if NAME}} ... {{/if}}    — conditional block, included only when NAME is bound

Validation:
    --require-nonempty-tag TAG  — fail if <TAG>...</TAG> is empty after render
    --ignore-tag-for-placeholders TAG — skip placeholder check inside <TAG>...</TAG>
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Optional


class TemplateError(RuntimeError):
    pass


class ValidationError(RuntimeError):
    pass


# --- Template AST ---

def parse_template_text(text: str) -> list:
    """Parse template into AST nodes: literal strings and conditional blocks."""
    nodes = []
    pattern = re.compile(r'\{\{#if\s+([A-Z][A-Z0-9_]*)\}\}(.*?)\{\{/if\}\}', re.DOTALL)
    last_end = 0

    for match in pattern.finditer(text):
        if match.start() > last_end:
            nodes.append(("literal", text[last_end:match.start()]))
        nodes.append(("conditional", match.group(1), match.group(2)))
        last_end = match.end()

    if last_end < len(text):
        nodes.append(("literal", text[last_end:]))

    return nodes


def render_nodes(nodes: list, bindings: dict[str, str]) -> str:
    """Render AST nodes with placeholder substitution."""
    parts = []
    for node in nodes:
        if node[0] == "literal":
            parts.append(node[1])
        elif node[0] == "conditional":
            name = node[1]
            body = node[2]
            if name in bindings and bindings[name].strip():
                parts.append(body)

    rendered = "".join(parts)

    # Substitute placeholders
    def replace_placeholder(match: re.Match) -> str:
        name = match.group(1)
        if name in bindings:
            return bindings[name]
        return match.group(0)  # Leave unbound placeholders as-is

    rendered = re.sub(r'\{([A-Z][A-Z0-9_]*)\}', replace_placeholder, rendered)
    return rendered


# --- Validation ---

def validate_rendered_prompt(
    rendered: str,
    require_nonempty_tags: list[str],
    ignore_tags_for_placeholders: list[str],
) -> None:
    """Validate the rendered prompt."""
    # Check required nonempty tags
    for tag in require_nonempty_tags:
        pattern = re.compile(rf'<{tag}>(.*?)</{tag}>', re.DOTALL)
        match = pattern.search(rendered)
        if not match:
            raise ValidationError(f"Required tag <{tag}> not found in rendered prompt")
        if not match.group(1).strip():
            raise ValidationError(f"Required tag <{tag}> is empty in rendered prompt")

    # Check for unsubstituted placeholders (excluding ignored tags)
    check_text = rendered
    for tag in ignore_tags_for_placeholders:
        check_text = re.sub(rf'<{tag}>.*?</{tag}>', '', check_text, flags=re.DOTALL)

    unbound = re.findall(r'\{([A-Z][A-Z0-9_]*)\}', check_text)
    if unbound:
        raise ValidationError(f"Unsubstituted placeholders: {', '.join(set(unbound))}")


# --- CLI ---

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Render a prompt template with placeholders and conditional blocks."
    )
    parser.add_argument(
        "--template", required=True, type=Path,
        help="Path to the template file to render."
    )
    parser.add_argument(
        "--set", action="append", default=[], metavar="NAME=VALUE",
        help="Bind a literal placeholder value."
    )
    parser.add_argument(
        "--set-file", action="append", default=[], metavar="NAME=PATH",
        help="Bind a placeholder value from a file."
    )
    parser.add_argument(
        "--require-nonempty-tag", action="append", default=[], metavar="TAG",
        help="Require that <TAG>...</TAG> is non-empty after render."
    )
    parser.add_argument(
        "--ignore-tag-for-placeholders", action="append", default=[], metavar="TAG",
        help="Ignore placeholder-like text inside <TAG>...</TAG>."
    )
    parser.add_argument(
        "--output", type=Path,
        help="Write rendered prompt to file (default: stdout)."
    )
    return parser.parse_args()


def parse_binding(raw: str) -> tuple[str, str]:
    if "=" not in raw:
        raise TemplateError(f"Binding must be NAME=VALUE, got: {raw!r}")
    name, value = raw.split("=", 1)
    if not re.fullmatch(r"[A-Z][A-Z0-9_]*", name):
        raise TemplateError(f"Invalid placeholder name: {name!r}")
    return name, value


def main() -> None:
    args = parse_args()

    # Read template
    template_text = args.template.read_text(encoding="utf-8")

    # Build bindings
    bindings: dict[str, str] = {}

    for raw in args.set:
        name, value = parse_binding(raw)
        if name in bindings:
            raise TemplateError(f"Duplicate binding for {name}")
        bindings[name] = value

    for raw in args.set_file:
        name, path_str = parse_binding(raw)
        if name in bindings:
            raise TemplateError(f"Duplicate binding for {name}")
        path = Path(path_str)
        if not path.exists():
            raise TemplateError(f"File not found for {name}: {path}")
        bindings[name] = path.read_text(encoding="utf-8")

    # Parse and render
    nodes = parse_template_text(template_text)
    rendered = render_nodes(nodes, bindings)

    # Validate
    validate_rendered_prompt(
        rendered,
        require_nonempty_tags=args.require_nonempty_tag,
        ignore_tags_for_placeholders=args.ignore_tag_for_placeholders,
    )

    # Output
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8")
        print(f"Rendered prompt written to: {args.output}")
    else:
        sys.stdout.write(rendered)


if __name__ == "__main__":
    try:
        main()
    except (TemplateError, ValidationError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)
