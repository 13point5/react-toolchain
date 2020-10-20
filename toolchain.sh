#!/bin/bash

# ----------------------
# Color Variables
# ----------------------
RED="\033[0;31m"
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
LCYAN='\033[1;36m'
NC='\033[0m' # No Color

# --------------------------------------
# Prompts for configuration preferences
# --------------------------------------

# Package Manager Prompt
echo
echo "Which package manager are you using?"
select package_command_choices in "Yarn" "npm" "Cancel"; do
  case $package_command_choices in
    Yarn ) pkg_cmd='yarn add'; break;;
    npm ) pkg_cmd='npm install'; break;;
    Cancel ) exit;;
  esac
done
echo

# File Format Prompt
echo "Which ESLint and Prettier configuration format do you prefer?"
select config_extension in ".js" ".json" "Cancel"; do
  case $config_extension in
    .js ) config_opening='module.exports = '; break;;
    .json ) config_opening=''; break;;
    Cancel ) exit;;
  esac
done
echo

# Checks for existing eslintrc files
if [ -f ".eslintrc.js" -o -f ".eslintrc.yaml" -o -f ".eslintrc.yml" -o -f ".eslintrc.json" -o -f ".eslintrc" ]; then
  echo -e "${RED}Existing ESLint config file(s) found:${NC}"
  ls -a .eslint* | xargs -n 1 basename
  echo
  echo -e "${RED}CAUTION:${NC} there is loading priority when more than one config file is present: https://eslint.org/docs/user-guide/configuring#configuration-file-formats"
  echo
  read -p  "Write .eslintrc${config_extension} (Y/n)? "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}>>>>> Skipping ESLint config${NC}"
    skip_eslint_setup="true"
  fi
fi

# ----------------------
# Perform Configuration
# ----------------------
echo
echo -e "${GREEN}Configuring your development environment... ${NC}"

echo
echo -e "${LCYAN}ESLint & Prettier Installation... ${NC}"
echo
$pkg_cmd -D eslint prettier eslint-plugin-react-hooks

echo
echo -e "${LCYAN}Husky & Lint-Staged Installation... ${NC}"
echo
$pkg_cmd -D husky lint-staged

echo
echo -e "${LCYAN}Conforming to Airbnb's JavaScript Style Guide... ${NC}"
echo
$pkg_cmd -D eslint-config-airbnb eslint-plugin-jsx-a11y eslint-plugin-import eslint-plugin-react babel-eslint

echo
echo -e "${LCYAN}Making ESlint and Prettier play nice with each other... ${NC}"
echo "See https://github.com/prettier/eslint-config-prettier for more details."
echo
$pkg_cmd -D eslint-config-prettier eslint-plugin-prettier

config_base_url="https://raw.githubusercontent.com/13point5/react-toolchain/main/config/"

configs=( eslint prettier husky lintstaged )

if [ "$skip_eslint_setup" == "true" ]; then
  break
else

  for config in ${configs[@]}
  do
    curr_config=".${config}rc${config_extension}"
    curr_config_url="${config_base_url}.${config}rc"
    
    echo
    echo -e "${YELLOW}Building your ${curr_config} file...${NC}"
    true > $curr_config

    curr_config_content=$(curl $curr_config_url)
    echo "${config_opening}${curr_config_content}" >> $curr_config
  done

fi

echo
echo -e "${GREEN}Finished setting up!${NC}"
echo
