ask() {
    local prompt default reply

    if [ "${2:-}" = "Y" ]; then
        prompt="Y/n"
        default=Y
    elif [ "${2:-}" = "N" ]; then
        prompt="y/N"
        default=N
    else
        prompt="y/n"
        default=
    fi

    while true; do

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -n "$1 [$prompt] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read reply </dev/tty

        # Default?
        if [ -z "$reply" ]; then
            reply=$default
        fi

        # Check if the reply is valid
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

if ask "Did you remeber to format the drive?" Y; then
    echo "Formatting the drive"
    mkfs.ext4 /dev/sda1

    echo "Mounting drive and chrooting"
    mount /dev/sda1 /mnt
    arch-chroot /mnt

    echo "Syncing Pacman and getting reflector mirrorlist"
    pacman -Syy
    pacman -S reflector

    echo "Country for pacman mirror"
    mirror_country=$(bash -c 'read -e -p "What country would you like to use for your pacman mirror: " tmp; echo $tmp')
    reflector -c mirror_country -f -l 10 -n 12 -save /etc/pacman.d/mirrorlist

    echo "Installing base system"
    pacman -S base
    pacman -S base-deval

    echo "Setting up GRUB"              
    pacman -S grub
    grub-install --target=i386-pc /dev/sda1

    echo "Installing Programs" 
    pacman
else
    echo "Use cfdisk /dev/sda to edit the drive"
fi

