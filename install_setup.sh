#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Step 1: Install Homebrew if it's not already installed ---
if ! command -v brew &> /dev/null
then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# --- Step 2: Install Ansible via Homebrew ---
echo "Installing Ansible..."
brew install ansible

# --- Step 3: Install the required Ansible collections ---
echo "Installing Ansible community.general collection..."
ansible-galaxy collection install community.general

# --- Step 4: Create the Ansible playbook file ---
echo "Creating the Ansible playbook file..."
cat > macos_apps.yml <<EOF
---
- name: Install macOS applications
  hosts: localhost
  connection: local
  tasks:
    - name: Install Mac App Store apps
      community.general.mas:
        name: "{{ item.name }}"
        state: present
      with_items:
        - { name: "Xcode", mas_id: 497799835 }
        - { name: "Pages", mas_id: 409201541 }

    - name: Install third-party software (Homebrew Casks)
      community.general.homebrew_cask:
        name: "{{ item }}"
        state: present
      with_items:
        - google-chrome
        - firefox
        - visual-studio-code
        - vlc
EOF

# --- Step 5: Execute the Ansible playbook ---
echo "Running the Ansible playbook to install applications..."
ansible-playbook macos_apps.yml

echo "All installations complete."
