confirm () {
    # call with a prompt string or use a default
    read -q response\?"${1:-Are you sure? [y/N] }"
    case $response in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}