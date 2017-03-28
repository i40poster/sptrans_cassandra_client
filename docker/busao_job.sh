for current_file in `ls routes_ids_clean_*` ; do
    (/root/busaoV2.sh $current_file &)
    #(cat $i &)
done
echo "End run MAIN:`date`" >> log_run_main_busao.txt
