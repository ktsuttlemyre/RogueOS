function rogue_secrets {
	bw logout
	while [ -z "$BW_SESSION" ]; do
		BW_SESSION=$(bw login --raw)
	done
	#get SecretsManager folder
	folder_id=$(bw list folders  --session "$BW_SESSION" | jq -r ".[] | select(.name==/"$1/").id")

	#parse bw item data
	list=$(bw list items --folderid "$folder_id"  --session "$BW_SESSION")

	while read -r id data path b64 gzip; do
		echo "Do whatever with ${id} ${data} ${path} ${b64} ${gzip}"
		if $b64; then
			data = echo "$data" | base64 --decode
		if $gzip; then
			#get list of files from tar
			#structure=echo "$data" | tar tzf - | awk -F/ '{ if($NF != "") print $NF }'
			#untar and unzip to current directory
			#echo "$data" | base64 --decode | tar -xzvf - -C .
		echo "$data" > "$path"

	done< <(echo "$list" | jq --raw-output '.[] | "\(.id) \(.notes) \(.fields[] | select(.name=="path").value) \(.fields[] | select(.name=="base64" || .name=="b64").value //false)"  \(.fields[] | select(.name=="gzip").value //false)"')
}

#example
# rogue_secrets 'Secrets:ShipDocker'

# #save session data
# save_data=$(tar -czvf - -T $structure | base64)
# echo "$save_data" | bw encode | bw edit item "$id"
# bw logout
