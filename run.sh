

for DESIGN in aes_cipher_top jpeg_encoder ibex_core ldpc_decoder_mod ariane NV_NVDLA_partition_c; do
	for CASE in 1 2 ; do
		### Flow 1 ###
		make DESIGN=$DESIGN PEX_TOOL1=innovus STA_TOOL1=innovus CC1=false SI1=false PEX_TOOL2=fusion_compiler STA_TOOL2=fusion_compiler CC2=false SI2=false CASE=$CASE 	
		make DESIGN=$DESIGN PEX_TOOL1=fusion_compiler STA_TOOL1=fusion_compiler CC1=false SI1=false PEX_TOOL2=innovus STA_TOOL2=innovus CC2=false SI2=false CASE=$CASE 	

		make DESIGN=$DESIGN PEX_TOOL1=innovus STA_TOOL1=innovus CC1=true SI1=true PEX_TOOL2=fusion_compiler STA_TOOL2=fusion_compiler CC2=true SI2=true CASE=$CASE 	
		make DESIGN=$DESIGN PEX_TOOL1=fusion_compiler STA_TOOL1=fusion_compiler CC1=true SI1=true PEX_TOOL2=innovus STA_TOOL2=innovus CC2=true SI2=true CASE=$CASE 	


		### Flow 2 ###
		make DESIGN=$DESIGN PEX_TOOL1=innovus STA_TOOL1=primetime CC1=false SI1=false PEX_TOOL2=fusion_compiler STA_TOOL2=primetime CC2=false SI2=false CASE=$CASE 	
		make DESIGN=$DESIGN PEX_TOOL1=fusion_compiler STA_TOOL1=primetime CC1=false SI1=false PEX_TOOL2=innovus STA_TOOL2=primetime CC2=false SI2=false CASE=$CASE 	

		make DESIGN=$DESIGN PEX_TOOL1=innovus STA_TOOL1=primetime CC1=true SI1=true PEX_TOOL2=fusion_compiler STA_TOOL2=primetime CC2=true SI2=true CASE=$CASE 	
		make DESIGN=$DESIGN PEX_TOOL1=fusion_compiler STA_TOOL1=primetime CC1=true SI1=true PEX_TOOL2=innovus STA_TOOL2=primetime CC2=true SI2=true CASE=$CASE 	

		#make DESIGN=$DESIGN PEX_TOOL1=innovus STA_TOOL1=tempus CC1=false SI1=false PEX_TOOL2=fusion_compiler STA_TOOL2=tempus CC2=false SI2=false CASE=$CASE 
		#make DESIGN=$DESIGN PEX_TOOL1=fusion_compiler STA_TOOL1=tempus CC1=false SI1=false PEX_TOOL2=innovus STA_TOOL2=tempus CC2=false SI2=false CASE=$CASE 

		#make DESIGN=$DESIGN PEX_TOOL1=innovus STA_TOOL1=tempus CC1=true SI1=true PEX_TOOL2=fusion_compiler STA_TOOL2=tempus CC2=true SI2=true CASE=$CASE 	
		#make DESIGN=$DESIGN PEX_TOOL1=fusion_compiler STA_TOOL1=tempus CC1=true SI1=true PEX_TOOL2=innovus STA_TOOL2=tempus CC2=true SI2=true CASE=$CASE 	


		### Flow 3 ###
		make DESIGN=$DESIGN PEX_TOOL1=quantus STA_TOOL1=tempus CC1=true SI1=true PEX_TOOL2=starRC STA_TOOL2=primetime CC2=true SI2=true CASE=$CASE 
		make DESIGN=$DESIGN PEX_TOOL1=starRC STA_TOOL1=primetime CC1=true SI1=true PEX_TOOL2=quantus STA_TOOL2=tempus CC2=true SI2=true CASE=$CASE
	done
done


