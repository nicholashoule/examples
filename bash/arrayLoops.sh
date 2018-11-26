#!/bin/bash
#Yuck!/usr/bin/env bash
###########################################
# SCRIPT INFORMATION
###########################################
# General - Variables               
###########################################
todaydate=$(date +%Y-%m-%d)
###########################################
# FUNCTION: log_file()
#
# Description:
# 	Ensure the log file exist that we pipe
#   our script's output to
###########################################
function log_file() {
	# Ensure the log file exists on the system
	if [[ ! -f "${LOG_FILE}" ]]; then
	  touch "${LOG_FILE}" || printf "[Failed]: %s.\\n%s\\n" "Could not create log file" "${LOG_FILE}" && return "$?"
	fi

	printf "[INFO]: %s, done.\\n" "Log file created"

}
###########################################
# FUNCTION: env_loop_check()
###########################################
env_loop_check() {
	# Loop through env array
	for e in "${!CI_ENV[@]}"; do
	    printf "[DEBUG] In the env loop %s\\n" "${e}"
		#printf "[DEBUG] CI_ENV %s\n" "${CI_ENV[$e]}"

		# Loop through environemnts array
	    printf "[%s][%s] Example %s\\n" "TEST" "${todaydate}" "${CI_ENV[${e}]}"

	    local t_env
	    t_env="$(echo -n "${e}" | tr '[:upper:]' '[:lower:]')"
	    printf "[DEBUG] t_env %s\\n" "${t_env}"
	    local PROJECT_ARRAY="CI_PROJECTS_${e}[@]"

	    # Loop through the project array
		for b in "${!PROJECT_ARRAY}"; do
			printf "[DEBUG] In the project loop %s\\n" "${b}"

				# Case for project array items
				case "${b}" in
					'Project 1 (Development)')
					    printf "[DEBUG] CASE %s\\n" "${b}"	
						t_name="project - ${CI_ENV[${e}]}"
						t_path="/opt/project/files/${t_env}/bin"
						;;
					'Project 1 (Production)')
						printf "[DEBUG] CASE %s\\n" "${b}"	
						t_name="project - ${CI_ENV[${e}]}"
						t_path="/opt/project/files/${t_env}/bin"
						;;				
					*) ;;
				esac
		done

	done
}
###########################################
# FUNCTION: get_github_env_repo()
###########################################
get_github_env_repo() {
	# GitHub project
	declare -r -l github_project_dev='https://raw.githubusercontent.com/nicholashoule/examples/master/files/dev/env.conf'
	declare -r -l github_project_prod='https://raw.githubusercontent.com/nicholashoule/examples/master/files/prod/env.conf'
	#declare -r github_key='x000000000000000000000000000000000000000000000'

	# GitHub: Development: dev
	if [[ -n "${github_project_dev}" ]]; then
		declare -g -a CI_PROJECTS_DEV
		printf "[%s][%s] %s\\n" "ENV" "${todaydate}" "GitHub: ${github_project_dev}"
		readarray -t CI_PROJECTS_DEV < <(curl -s "${github_project_dev}")
		#readarray -t CI_PROJECTS_DEV < <(curl -s -H "Authorization: token ${github_key}" "${github_project_dev}")
		#printf "%s\\n" "${CI_PROJECTS_DEV[@]}"
	fi

	# GitHub: Production: prod
	if [[ -n "${github_project_prod}" ]]; then
		declare -g -a CI_PROJECTS_PROD
		printf "[%s][%s] %s\\n" "ENV" "${todaydate}" "GitHub: ${github_project_prod}"
		readarray -t CI_PROJECTS_PROD < <(curl -s "${github_project_prod}")
		#readarray -t CI_PROJECTS_PROD < <(curl -s -H "Authorization: token ${github_key}" "${github_project_prod}")
		#printf "%s\\n" "${CI_PROJECTS_PROD[@]}"
	fi

}
################################################################################
# Environments
################################################################################
declare -r -A CI_ENV=(["DEV"]="Development" ["PROD"]="Production")
###########################################
# MAIN()
#
# Default setup:
#	env_binary_file_check
#
###########################################
main() {
	# Default setup
	printf "[%s][%s] %s\\n" "Examples" "$(date)" "TEST"
	get_github_env_repo
	# Run binary sync
	env_loop_check
}
main