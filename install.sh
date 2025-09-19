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

# --- Step 2: Install Ansible and mas via Homebrew ---
echo "Installing Ansible and the 'mas' tool..."
brew install ansible mas

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
        id: "{{ item.id }}"
        state: present
      with_items:
        - { name: "Xcode", id: 497799835 }
        - { name: "Amphetamine", id: 937984704 }
        - { name: "BitWarden", id: 1352778147 }
        - { name: "Cyberduck", id: 409222199 }
        - { name: "Hogwasher", id: 1000674035 }
        - { name: "LibreOffice", id: 1630474372 }
        - { name: "NextDNS", id: 1464122853 }
        - { name: "UTM", id: 1538878817 }
        - { name: "WireGuard", id: 1451685025 }
        - { name: "Kagi", id: 1622835804 }
        - { name: "Dark Reader", id: 1438243180 }
        - { name: "xSearch", id: 1579902068 }

    - name: Install third-party software (Homebrew Casks)
      community.general.homebrew_cask:
        name: "{{ item }}"
        state: present
      with_items:
        - firefox
        - vlc
        - sublime-text
        - wireshark-app
        - raspberry-pi-imager
        - balenaetcher
EOF

# --- Step 5: Execute the Ansible playbook ---
echo "Running the Ansible playbook to install applications..."
ansible-playbook macos_apps.yml

echo "All installations complete."
