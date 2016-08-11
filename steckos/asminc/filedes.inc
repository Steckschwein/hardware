;--------------------------------------------------------------------------------------
; File Descriptor Stuff
;--------------------------------------------------------------------------------------
;.data

fd_area						= $0320 ; File descriptor area until $0350 
FD_Entries_Max = 16
FD_Entry_Size = 9 ; 9 byte per fd entry

FD_start_cluster = $00	; 32 Bit cluster nr
FD_file_size = $04		; 32 Bit file size
FD_file_attr = $08		; 8 Bit fat32 Attributes

FD_INDEX_CURRENT_DIR = 0			    ; current dir always go to fd #0
FD_INDEX_TEMP_DIR    = FD_Entry_Size    ; temp dir always go to fd #1


FD_ATTR_DIR				= 1<<4;
FD_ATTR_FILE			= 1<<5;