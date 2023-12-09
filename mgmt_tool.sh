#!/bin/ash

USERS_DIR="/etc/freeradius3/management/users"
AUTHORIZE_FILE="/etc/freeradius3/management/authorize"
AUTHORIZE_ORIGINAL="/etc/freeradius3/management/authorize_original"
MODS_CONFIG_DIR="/etc/freeradius3/mods-config/files"

function createUser() {
    echo "Enter username:"
    read username
    echo "Enter password:"
    read password

    echo -e "${username}\tCleartext-Password := \"${password}\"" > "${USERS_DIR}/${username}"
    updateAuthorizeFile
}

function changePassword() {
    echo "Enter username:"
    read username
    if [ ! -f "${USERS_DIR}/${username}" ]; then
        echo "User not found."
        return
    fi

    echo "Enter new password:"
    read password

    echo -e "${username}\tCleartext-Password := \"${password}\"" > "${USERS_DIR}/${username}"
    updateAuthorizeFile
}

function deleteUser() {
    echo "Enter username to delete:"
    read username

    if [ -f "${USERS_DIR}/${username}" ]; then
        rm "${USERS_DIR}/${username}"
        updateAuthorizeFile
    else
        echo "User not found."
    fi
}

function updateAuthorizeFile() {
    [ -f "${AUTHORIZE_FILE}" ] && rm "${AUTHORIZE_FILE}"
    touch "${AUTHORIZE_FILE}"

    for userfile in "${USERS_DIR}"/*; do
        if [ -f "$userfile" ]; then
            cat "$userfile" >> "${AUTHORIZE_FILE}"
            echo "" >> "${AUTHORIZE_FILE}" # Add a newline for separation
        fi
    done

    cat "${AUTHORIZE_ORIGINAL}" >> "${AUTHORIZE_FILE}"
}

function copyToModsConfig() {
    cp "${AUTHORIZE_FILE}" "${MODS_CONFIG_DIR}/authorize"
}

while true; do
    echo "Choose an option:"
    echo "1) Create a new user"
    echo "2) Change a user's password"
    echo "3) Delete a user"
    echo "4) Exit"
    read -p "Option: " option

    case $option in
        1) createUser ;;
        2) changePassword ;;
        3) deleteUser ;;
        4) copyToModsConfig; break ;;
        *) echo "Invalid option. Please try again." ;;
    esac
done
