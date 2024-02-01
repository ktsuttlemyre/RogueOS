#! /bin/bash
#reads all secrets from a bitwarden folder and loads them based on their path field
#rogue_secret_notes is the value
#rogue_secret_field_path is where to put the value (- is shell environment)
#rogue_secret_field_base64 means it is base 64 encoded
#rogue_secret_field_gzip means it is gzipped

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

debug=false

#add log4bash and debug flag
source $script_dir/libs/log4bash/log4bash.sh
if ! [ debug ]; then
	log_debug()  { :; }
fi

secret_folder=$1
echo "========================================="
echo "Installing scripts from $secret_folder" 
echo "========================================="
bw logout || true
unset BW_SESSION
while [ -z "$BW_SESSION" ]; do
	BW_SESSION=$(bw login --raw)
done
#get SecretsManager folder
folder_id=$(bw list folders  --session "$BW_SESSION" | jq -r ".[] | select(.name==\"$secret_folder\").id")

#parse bw item data
list=$(bw list items --folderid "$folder_id"  --session "$BW_SESSION")

log_warning "$list"
log_info "$list"

#iterate the secrets array
echo $list |jq -c '.[]' | while read i; do

	#load the secret object into prefixed bash variables 
	while read -rd $'' entry; do
		export "rogue_secret_$entry"
		log_info "rogue_secret_$entry::::"
		log_debug "$entry"
		log_warning "$i"
	done < <(jq -rj <<<"$i" \
			 'to_entries|map("\(.key)=\(.value|tostring)\u0000")[]');
	#got above anser from https://unix.stackexchange.com/questions/515573/convert-json-file-to-a-key-path-with-the-resulting-value-at-the-end-of-each-k

	#if there is a fields area then itereate the fields array of objects
	if ! [ -z ${rogue_secret_fields+x} ]; then 
		log_debug "found secret fields $rogue_secret_fields"
		while read j; do
			#log_debug "$j"
			#load them into bash variables
			while read -rd $'' field; do
				export "rogue_secret_field_tmp_$field"
				#log_debug  "$field"
			done < <(jq -rj <<<"$j" \
				'to_entries|map("\(.key)=\(.value|tostring)\u0000")[]')

		#fix the scope of the vairable namespace
		export "rogue_secret_field_$rogue_secret_field_tmp_name=$rogue_secret_field_tmp_value"
		log_debug "exporting rogue_secret_field_$rogue_secret_field_tmp_name=$rogue_secret_field_tmp_value"
		done <<< "$(echo $rogue_secret_fields |jq -c '.[]' )"
		#clean up the environment
		printenv |  grep '^rogue_secret_field_tmp_' | sed 's;=.*;;' | while read var_name; do
			log_debug "unsetting $var_name"
			unset $var_name
		done

	fi
	rogue_secret_notes=$(echo "$rogue_secret_notes" | tr '\0' '\n')
	#####
	# All values are set
	#rogue_secret_notes is the value
	#rogue_secret_field_path is where to put the value (- is shell environment)
	#rogue_secret_field_base64 means it is base 64 encoded
	#rogue_secret_field_gzip means it is gzipped
	#####

	#if $rogue_secret_field_base64; then
	#	data = echo "$data" | base64 --decode
	#if $rogue_secret_field_gzip; then
		#get list of files from tar
		#structure=echo "$data" | tar tzf - | awk -F/ '{ if($NF != "") print $NF }'
		#untar and unzip to current directory
		#echo "$data" | base64 --decode | tar -xzvf - -C .

	log_debug "path is $rogue_secret_field_path"
	if [ -z ${rogue_secret_field_path+x} ]; then
		# load as envirnment variable
		log_debug "exporting $rogue_secret_name to shell environment"
		export "${rogue_secret_name}=$rogue_secret_notes"
	else
		#make the file
		log_debug "writing $rogue_secret_name to $rogue_secret_field_path"
		rogue_secret_field_path_only="$(dirname "${rogue_secret_field_path}")"
		log_debug $rogue_secret_field_path
		log_debug $rogue_secret_field_path_only
		if ! [[ $rogue_secret_field_path_only == ~* ]]; then
			mkdir -p $rogue_secret_field_path_only
		else
			rogue_secret_field_path="${rogue_secret_field_path/#\~/$HOME}"
		fi
		echo "$rogue_secret_notes" > $rogue_secret_field_path
	fi

	#clean up the environment
	printenv |  grep '^rogue_secret' | sed 's;=.*;;' | while read var_name; do
		unset $var_name
	done
done
bw logout
unset BW_SESSION




#example
# rogue_secrets 'Secrets:ShipDocker'

# #save session data
# save_data=$(tar -czvf - -T $structure | base64)
# echo "$save_data" | bw encode | bw edit item "$id"
# bw logout