#!/usr/bin/env python3
"""
Quick dependency check for Mini Vector Search Playground.
Run this after installing requirements to ensure everything works.
"""

import sys

def check_package(name):
    try:
        mod = __import__(name)
        version = getattr(mod, "__version__", "unknown")
        print(f"✅ {name} ({version}) is installed")
    except ImportError:
        print(f"❌ {name} is NOT installed")
    except Exception as e:
        print(f"⚠️ Error checking {name}: {e}")

def main():
    print("🔍 Checking dependencies...\n")

    pkgs = [
        "fastapi",
        "uvicorn",
        "pandas",
        "httpx",
        "chromadb",
        "pydantic",
    ]

    for pkg in pkgs:
        check_package(pkg)

    print("\n✨ Environment check complete!")
    print(f"Python version: {sys.version.split()[0]}")

if __name__ == "__main__":
    main()

