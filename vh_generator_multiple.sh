while IFS= read -r line; do
    ./virtual_host_generator.sh $line
done < domain_list.txt
