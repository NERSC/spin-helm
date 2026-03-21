#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path
import sys

import yaml
from jinja2 import Environment, FileSystemLoader, StrictUndefined


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description='Render values.yaml from a YAML config file and Jinja template.'
    )
    parser.add_argument(
        'config',
        nargs='?',
        default='prepare-values.yaml',
        help='Path to the YAML config file. Default: prepare-values.yaml',
    )
    parser.add_argument(
        '--template',
        default='values_template.yaml',
        help='Path to the Jinja values template. Default: values_template.yaml',
    )
    parser.add_argument(
        '--output',
        default='values.yaml',
        help='Path to the rendered values file. Default: values.yaml',
    )
    return parser


def load_yaml(path: Path) -> dict:
    with path.open('r', encoding='utf-8') as fh:
        data = yaml.safe_load(fh) or {}
    if not isinstance(data, dict):
        raise ValueError(f'{path} must contain a YAML mapping at the top level.')
    return data


def derive_fields(config: dict) -> dict:
    rendered = dict(config)

    if 'webserver_existing' not in rendered:
        use_case = rendered.get('use_case')
        if use_case == 'case1':
            rendered['webserver_existing'] = True
        elif use_case == 'case2':
            rendered['webserver_existing'] = False
        else:
            raise ValueError(
                'Set webserver_existing explicitly, or set use_case to case1 or case2.'
            )

    user_domains = rendered.get('user_domains')
    if not isinstance(user_domains, list) or not user_domains:
        raise ValueError('user_domains must be a non-empty YAML list.')
    if not all(isinstance(domain, str) and domain for domain in user_domains):
        raise ValueError('Each entry in user_domains must be a non-empty string.')

    return rendered


def render(template_path: Path, context: dict) -> str:
    env = Environment(
        loader=FileSystemLoader(str(template_path.parent)),
        undefined=StrictUndefined,
        trim_blocks=True,
        lstrip_blocks=True,
    )
    template = env.get_template(template_path.name)
    return template.render(**context)


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    config_path = Path(args.config).resolve()
    template_path = Path(args.template).resolve()
    output_path = Path(args.output).resolve()

    if not config_path.exists():
        print(
            f'Error: config file not found: {config_path}\n'
            f'Hint: copy {config_path.parent / "prepare-values.yaml.example"} '
            f'to {config_path.parent / "prepare-values.yaml"} and edit it.',
            file=sys.stderr,
        )
        return 1

    try:
        config = derive_fields(load_yaml(config_path))
        rendered = render(template_path, config)
    except Exception as exc:
        print(f'Error: {exc}', file=sys.stderr)
        return 1

    output_path.write_text(rendered, encoding='utf-8')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
