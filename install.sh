#!/bin/sh

# This script is for installing the latest version of Turso CLI on your machine.

set -e

# Terminal ANSI escape codes.
reset="\033[0m"
bright_blue="${reset}\033[34;1m"

probe_arch() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="x86_64"  ;;
        aarch64) ARCH="arm64" ;;
        arm64) ARCH="arm64" ;;
        *) printf "Architecture ${ARCH} is not supported by this installation script\n"; exit 1 ;;
    esac
}

probe_os() {
    OS=$(uname -s)
    case $OS in
        Darwin) OS="Darwin" ;;
        Linux) OS="Linux" ;;
        MINGW*|MSYS*|CYGWIN*|Windows_NT)
            OS="Windows"
            ;;
        *) printf "Operating system ${OS} is not supported by this installation script\n"; exit 1 ;;
    esac
}

print_logo() {
    printf "${bright_blue}
                 .:                                 .:
  .\$\$.   \$\$:   .\$\$\$:                                \$\$\$^    \$\$:   ~\$^
  .\$\$\$!:\$\$\$  .\$\$\$\$~                                 .\$\$\$\$^  !\$\$~^\$\$\$~
    \$\$\$\$\$\$ .\$\$\$\$\$~                                   .\$\$\$\$\$^ \$\$\$\$\$\$:
     !\$\$\$\$\$\$\$\$\$\$~                                     .\$\$\$\$\$\$\$\$\$\$\$
      :\$\$\$\$\$\$\$\$~                                       .\$\$\$\$\$\$\$\$!
     .\$\$\$\$\$\$\$\$~                                         .\$\$\$\$\$\$\$\$^
    .\$\$\$\$\$\$\$\$!       ~\$!                       :\$\$.      :\$\$\$\$\$\$\$\$^
     \$\$\$\$\$\$\$\$\$\$\$!^::\$\$\$\$\$^...................:\$\$\$\$\$!.^~\$\$\$\$\$\$\$\$\$\$\$:
     \$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$
     :\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$!
        :^!\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$~:.
           :\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$!
      \$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$:
      :\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$~
        ^\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$~.
           :\$\$\$\$\$:   .^~!\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$!^:.   \$\$\$\$\$!
           :\$\$\$\$\$!.         .!\$\$\$\$\$\$\$\$\$\$\$\$.         .^\$\$\$\$\$!
           :\$\$\$\$\$\$\$\$\$\$!^:.   ~\$\$\$\$\$\$\$\$\$\$\$\$    .^~\$\$\$\$\$\$\$\$\$\$!
           :\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$. ~\$\$\$\$\$\$\$\$\$\$\$\$  \$\$\$\$\$\$\$\$\$\$\$\$\$\$\$!
           :\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$: ~\$\$\$\$\$\$\$\$\$\$\$\$  \$\$\$\$\$\$\$\$\$\$\$\$\$\$\$!
           :\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$^ ~\$\$\$\$\$\$\$\$\$\$\$\$  \$\$\$\$\$\$\$\$\$\$\$\$\$\$\$!
           :\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$~ ~\$\$\$\$\$\$\$\$\$\$\$\$  \$\$\$\$\$\$\$\$\$\$\$\$\$\$\$!
           :\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$~^^:.     ..:^~!\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$!
           ^\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$!
           :\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$~
            :\$\$\$\$\$\$\$\$\$\$\$\$\$:\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$~~\$\$\$\$\$\$\$\$\$\$\$\$~
              !\$\$\$\$\$\$\$\$\$\$. :\$\$..\$\$! :\$\$^ !\$!  ~\$\$\$\$\$\$\$\$\$\$.
               ^\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$!
                 \$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$:
                  ~\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$
                   "\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$"
                     \$\$\$\$\$~\$\$\$\$\$^\$\$\$\$\$~\$\$\$\$\$\$~\$\$\$\$:
                      \$\$^  .\$\$\$   \$\$\$:  ~\$\$^  .\$\$^
                      ..     :     :     :.     :
${reset}
"
}

detect_profile() {
  local DETECTED_PROFILE
  DETECTED_PROFILE=''
  local SHELLTYPE
  SHELLTYPE="$(basename "/$SHELL")"

  if [ "$SHELLTYPE" = "bash" ]; then
    if [ -f "$HOME/.bashrc" ]; then
      DETECTED_PROFILE="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
      DETECTED_PROFILE="$HOME/.bash_profile"
    fi
  elif [ "$SHELLTYPE" = "zsh" ]; then
    DETECTED_PROFILE="${ZDOTDIR:-$HOME}/.zshrc"
  elif [ "$SHELLTYPE" = "fish" ]; then
    DETECTED_PROFILE="$HOME/.config/fish/conf.d/turso.fish"
  fi

  if [ -z "$DETECTED_PROFILE" ]; then
    if [ -f "$HOME/.profile" ]; then
      DETECTED_PROFILE="$HOME/.profile"
    elif [ -f "$HOME/.bashrc" ]; then
      DETECTED_PROFILE="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
      DETECTED_PROFILE="$HOME/.bash_profile"
    elif [ -f "${ZDOTDIR:-$HOME}/.zshrc" ]; then
      DETECTED_PROFILE="${ZDOTDIR:-$HOME}/.zshrc"
    elif [ -d "$HOME/.config/fish" ]; then
      DETECTED_PROFILE="$HOME/.config/fish/conf.d/turso.fish"
    fi
  fi

  if [ ! -z "$DETECTED_PROFILE" ]; then
    echo "$DETECTED_PROFILE"
  fi
}

update_profile() {
   PROFILE_FILE=$(detect_profile)
   if [ -n "$PROFILE_FILE" ]; then
     if ! grep -q "\.turso" $PROFILE_FILE; then
        printf "\n${bright_blue}Updating profile ${reset}$PROFILE_FILE\n"
        printf "\n# Turso\nexport PATH=\"\$PATH:$INSTALL_DIRECTORY\"\n" >> $PROFILE_FILE
        printf "\nTurso will be available when you open a new terminal.\n"
        printf "If you want to make Turso available in this terminal, please run:\n"
        printf "\nsource $PROFILE_FILE\n"
     fi
   else
     printf "\n${bright_blue}Unable to detect profile file location. ${reset}Please add the following to your profile file:\n"
     printf "\nexport PATH=\"$INSTALL_DIRECTORY:\$PATH\"\n"
   fi
}

install_turso_cli() {
  URL_PREFIX="${TURSO_DOWNLOAD_BASE:-https://github.com/tursodatabase/homebrew-tap/releases/latest/download}"
  URL_PREFIX="${URL_PREFIX%/}"
  TARGET="${OS}_$ARCH"

  printf "${bright_blue}Downloading ${reset}$TARGET ...\n"
  mkdir -p "$INSTALL_DIRECTORY"

  if [ -n "${TURSO_INSTALL_ZIP:-}" ]; then
    DOWNLOAD_FILE="$TURSO_INSTALL_ZIP"
    printf "${bright_blue}Using local archive ${reset}$DOWNLOAD_FILE\n"
  elif [ "$OS" = "Windows" ]; then
    URL="$URL_PREFIX/homebrew-tap_$TARGET.zip"
    DOWNLOAD_FILE=$(mktemp -t turso.XXXXXXXXXX.zip)
    curl --progress-bar -L "$URL" -o "$DOWNLOAD_FILE"
  else
    URL="$URL_PREFIX/homebrew-tap_$TARGET.tar.gz"
    DOWNLOAD_FILE=$(mktemp -t turso.XXXXXXXXXX)
    curl --progress-bar -L "$URL" -o "$DOWNLOAD_FILE"
  fi

  printf "\n${bright_blue}Installing to ${reset}$INSTALL_DIRECTORY\n"
  if [ "$OS" = "Windows" ]; then
    EXTRACT_DIR=$(mktemp -d -t turso-extract.XXXXXXXXXX)
    # Git Bash ships with unzip; fall back to tar which can read zip on modern builds.
    if command -v unzip >/dev/null 2>&1; then
      unzip -o -q "$DOWNLOAD_FILE" -d "$EXTRACT_DIR"
    else
      tar -C "$EXTRACT_DIR" -xf "$DOWNLOAD_FILE"
    fi
    EXE=$(find "$EXTRACT_DIR" -name 'turso.exe' | head -n 1)
    if [ -z "$EXE" ]; then
      printf "turso.exe was not found inside the release archive\n"
      exit 1
    fi
    cp "$EXE" "$INSTALL_DIRECTORY/turso.exe"
    rm -rf "$EXTRACT_DIR"
    if [ -z "${TURSO_INSTALL_ZIP:-}" ]; then
      rm -f "$DOWNLOAD_FILE"
    fi
  else
    tar -C "$INSTALL_DIRECTORY" -zxf "$DOWNLOAD_FILE" turso
    if [ -z "${TURSO_INSTALL_ZIP:-}" ]; then
      rm -f "$DOWNLOAD_FILE"
    fi
  fi
}

install_libsql_server() {
    if [ "$OS" = "Windows" ]; then
        printf "${bright_blue}Skipping libsql-server${reset}: no native Windows build is published yet.\n"
        printf "The Turso Cloud CLI itself is installed natively; use Turso Cloud or a remote sqld.\n"
        return 0
    fi

    case $ARCH in
        x86_64) ARCH_TARGET="x86_64" ;;
        aarch64) ARCH_TARGET="aarch64" ;;
        arm64) ARCH_TARGET="aarch64" ;;
        *)
            printf "Architecture ${ARCH} is not supported for libsql-server\n"
            return 1
            ;;
    esac

    case $OS in
        Darwin) OS_TARGET="apple-darwin" ;;
        Linux) OS_TARGET="unknown-linux-gnu" ;;
        *)
            printf "Operating system ${OS} is not supported for libsql-server\n"
            return 1
            ;;
    esac

    LIBSQL_TARGET="libsql-server-${ARCH_TARGET}-${OS_TARGET}"
    LIBSQL_TAR="${LIBSQL_TARGET}.tar.xz"
    LIBSQL_URL_PREFIX="https://github.com/tursodatabase/libsql/releases/latest/download"
    LIBSQL_URL="${LIBSQL_URL_PREFIX}/${LIBSQL_TAR}"

    LIBSQL_DOWNLOAD_FILE=$(mktemp -t turso-libsql.XXXXXXXXXX)
    curl --progress-bar -L "$LIBSQL_URL" -o "$LIBSQL_DOWNLOAD_FILE"
    printf "\n${bright_blue}Installing libsql-server to ${reset}$INSTALL_DIRECTORY\n"
    mkdir -p $INSTALL_DIRECTORY
    tar --strip-components=1 -C $INSTALL_DIRECTORY -xJf $LIBSQL_DOWNLOAD_FILE $LIBSQL_TARGET/sqld
    rm -f $LIBSQL_DOWNLOAD_FILE
}

# do everything in main, so that partial downloads of this file don't mess up the installation
main() {
  printf "\nWelcome to the Turso installer!\n"

  print_logo
  probe_arch
  probe_os

  INSTALL_DIRECTORY="${TURSO_INSTALL_DIR:-$HOME/.turso}"
  install_libsql_server
  install_turso_cli
  update_profile

  printf "\nTurso CLI installed!\n\n"
  printf "If you are a new user, you can sign up with ${bright_blue}turso auth signup${reset}.\n\n"
  printf "If you already have an account, please login with ${bright_blue}turso auth login${reset}.\n\n"
}

main
