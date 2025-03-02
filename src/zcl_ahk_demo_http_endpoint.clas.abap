" https://software-heroes.com/en/blog/btp-http-service-endpoint

CLASS zcl_ahk_demo_http_endpoint DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.

    " Define the structure that matches the JSON payload
    TYPES: BEGIN OF ty_sales_order_create_request,
             order_header_in     TYPE bapisdhd1,
             order_items_in      TYPE STANDARD TABLE OF bapisditm WITH DEFAULT KEY,
             order_partners      TYPE STANDARD TABLE OF bapiparnr WITH DEFAULT KEY,
             order_schedules_in  TYPE STANDARD TABLE OF bapischdl WITH DEFAULT KEY,
             order_conditions_in TYPE STANDARD TABLE OF bapicond WITH DEFAULT KEY,
             order_cfgs_ref      TYPE STANDARD TABLE OF bapicucfg WITH DEFAULT KEY,
             order_cfgs_inst     TYPE STANDARD TABLE OF bapicuins WITH DEFAULT KEY,
             order_cfgs_part_of  TYPE STANDARD TABLE OF bapicuprt WITH DEFAULT KEY,
             order_cfgs_value    TYPE STANDARD TABLE OF bapicuval WITH DEFAULT KEY,
             order_cfgs_blob     TYPE STANDARD TABLE OF bapicublb WITH DEFAULT KEY,
             order_cfgs_vk       TYPE STANDARD TABLE OF bapicuvk WITH DEFAULT KEY,
             order_cfgs_refinst  TYPE STANDARD TABLE OF bapicuref WITH DEFAULT KEY,
             order_ccard         TYPE STANDARD TABLE OF bapiccard WITH DEFAULT KEY,
             order_text          TYPE STANDARD TABLE OF bapisdtext WITH DEFAULT KEY,
             order_keys          TYPE STANDARD TABLE OF bapisdkey WITH DEFAULT KEY,
             extensionin         TYPE STANDARD TABLE OF bapiparex WITH DEFAULT KEY,
             partneraddresses    TYPE STANDARD TABLE OF bapiaddr1 WITH DEFAULT KEY,
             extensionex         TYPE STANDARD TABLE OF bapiparex WITH DEFAULT KEY,
           END OF ty_sales_order_create_request.

    TYPES: BEGIN OF ty_sales_order_create_internal,
             order_header_in      TYPE bapisdhd1,
             order_header_inx     TYPE bapisdhd1x,
             return_messages      TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY,
             order_items_in       TYPE STANDARD TABLE OF bapisditm WITH DEFAULT KEY,
             order_items_inx      TYPE STANDARD TABLE OF bapisditmx WITH DEFAULT KEY,
             order_partners       TYPE STANDARD TABLE OF bapiparnr WITH DEFAULT KEY,
             order_schedules_in   TYPE STANDARD TABLE OF bapischdl WITH DEFAULT KEY,
             order_schedules_inx  TYPE STANDARD TABLE OF BAPISCHDLx WITH DEFAULT KEY,
             order_conditions_in  TYPE STANDARD TABLE OF bapicond WITH DEFAULT KEY,
             order_conditions_inx TYPE STANDARD TABLE OF BAPICONDx WITH DEFAULT KEY,
             order_cfgs_ref       TYPE STANDARD TABLE OF bapicucfg WITH DEFAULT KEY,
             order_cfgs_inst      TYPE STANDARD TABLE OF bapicuins WITH DEFAULT KEY,
             order_cfgs_part_of   TYPE STANDARD TABLE OF bapicuprt WITH DEFAULT KEY,
             order_cfgs_value     TYPE STANDARD TABLE OF bapicuval WITH DEFAULT KEY,
             order_cfgs_blob      TYPE STANDARD TABLE OF bapicublb WITH DEFAULT KEY,
             order_cfgs_vk        TYPE STANDARD TABLE OF bapicuvk WITH DEFAULT KEY,
             order_cfgs_refinst   TYPE STANDARD TABLE OF bapicuref WITH DEFAULT KEY,
             order_ccard          TYPE STANDARD TABLE OF bapiccard WITH DEFAULT KEY,
             order_text           TYPE STANDARD TABLE OF bapisdtext WITH DEFAULT KEY,
             order_keys           TYPE STANDARD TABLE OF bapisdkey WITH DEFAULT KEY,
             extensionin          TYPE STANDARD TABLE OF bapiparex WITH DEFAULT KEY,
             partneraddresses     TYPE STANDARD TABLE OF bapiaddr1 WITH DEFAULT KEY,
             extensionex          TYPE STANDARD TABLE OF bapiparex WITH DEFAULT KEY,
           END OF ty_sales_order_create_internal.

  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA lv_json_payload         TYPE string.
    DATA ls_sales_order_payload  TYPE ty_sales_order_create_request.
    DATA ls_sales_order_internal TYPE ty_sales_order_create_internal.

    METHODS _create_sales_order
      IMPORTING is_sales_order_internal          TYPE ty_sales_order_create_internal
      RETURNING VALUE(rv_created_sales_order_no) TYPE bapivbeln-vbeln.

    METHODS _map_request_to_internal
      IMPORTING is_request         TYPE ty_sales_order_create_request
      RETURNING VALUE(rs_internal) TYPE ty_sales_order_create_internal.

    METHODS _fill_x_structure_dynamic
      IMPORTING is_source TYPE any
      CHANGING  cs_target TYPE any.

    METHODS _fill_x_table_dynamic
      IMPORTING it_source TYPE ANY TABLE
      CHANGING  ct_target TYPE ANY TABLE.
ENDCLASS.


CLASS zcl_ahk_demo_http_endpoint IMPLEMENTATION.
  METHOD if_http_service_extension~handle_request.
    CASE request->get_method( ).
*      WHEN 'GET'.

*      WHEN 'PUT'.

*      WHEN 'DELETE'.

      WHEN 'POST'.
        TRY.
            " Retrieve JSON payload from the HTTP body
            lv_json_payload = request->get_text( ).

            " Deserialize JSON payload into ABAP structure
            /ui2/cl_json=>deserialize( EXPORTING json = lv_json_payload
                                       CHANGING  data = ls_sales_order_payload ).

            ls_sales_order_internal = _map_request_to_internal( ls_sales_order_payload ).

            DATA(lv_created_sales_order_no) = _create_sales_order( is_sales_order_internal = ls_sales_order_internal ).

            IF lv_created_sales_order_no IS NOT INITIAL.
              " Set successful response
              response->set_status( i_code   = 200
                                    i_reason = 'OK' ).
              response->set_text(
                  |"status": "success", "message": "Sales Order { lv_created_sales_order_no } created successfully"| ).
            ELSE.
              response->set_status( i_code   = 422
                                    i_reason = 'Unprocessable Entity' ).
              response->set_text(
                  |"status":"error","message":"Sales Order could not be created due to validation errors or missing data."| ).
            ENDIF.

          CATCH cx_root INTO DATA(lx).
            " Handle errors and return proper response
            response->set_status( i_code   = 500
                                  i_reason = 'Internal Server Error' ).
            response->set_text( |"status": "error", "message": "{ lx->get_text( ) }"| ).
        ENDTRY.

    ENDCASE.
  ENDMETHOD.

  METHOD _create_sales_order.
    DATA ls_order_header_in        TYPE bapisdhd1.
    DATA ls_order_header_inx       TYPE bapisdhd1x.
    DATA lt_return_messages        TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lt_order_items_in         TYPE STANDARD TABLE OF bapisditm WITH DEFAULT KEY.
    DATA lt_order_items_inx        TYPE STANDARD TABLE OF bapisditmx WITH DEFAULT KEY.
    DATA lt_order_partners         TYPE STANDARD TABLE OF bapiparnr WITH DEFAULT KEY.
    DATA lt_order_schedules_in     TYPE STANDARD TABLE OF bapischdl WITH DEFAULT KEY.
    DATA lt_order_schedules_inx    TYPE STANDARD TABLE OF BAPISCHDLx WITH DEFAULT KEY.
    DATA lt_order_conditions_in    TYPE STANDARD TABLE OF bapicond WITH DEFAULT KEY.
    DATA lt_order_conditions_inx   TYPE STANDARD TABLE OF BAPICONDx WITH DEFAULT KEY.
    DATA lt_order_cfgs_ref         TYPE STANDARD TABLE OF bapicucfg WITH DEFAULT KEY.
    DATA lt_order_cfgs_inst        TYPE STANDARD TABLE OF bapicuins WITH DEFAULT KEY.
    DATA lt_order_cfgs_part_of     TYPE STANDARD TABLE OF bapicuprt WITH DEFAULT KEY.
    DATA lt_order_cfgs_value       TYPE STANDARD TABLE OF bapicuval WITH DEFAULT KEY.
    DATA lt_order_cfgs_blob        TYPE STANDARD TABLE OF bapicublb WITH DEFAULT KEY.
    DATA lt_order_cfgs_vk          TYPE STANDARD TABLE OF bapicuvk WITH DEFAULT KEY.
    DATA lt_order_cfgs_refinst     TYPE STANDARD TABLE OF bapicuref WITH DEFAULT KEY.
    DATA lt_order_ccard            TYPE STANDARD TABLE OF bapiccard WITH DEFAULT KEY.
    DATA lt_order_text             TYPE STANDARD TABLE OF bapisdtext WITH DEFAULT KEY.
    DATA lt_order_keys             TYPE STANDARD TABLE OF bapisdkey WITH DEFAULT KEY.
    DATA lt_extensionin            TYPE STANDARD TABLE OF bapiparex WITH DEFAULT KEY.
    DATA lt_partneraddresses       TYPE STANDARD TABLE OF bapiaddr1 WITH DEFAULT KEY.
    DATA lt_extensionex            TYPE STANDARD TABLE OF bapiparex WITH DEFAULT KEY.

    DATA lv_created_sales_order_no TYPE bapivbeln-vbeln.

    " To prevent conversion errors, explicit assignment for type compatibility with BAPI parameters
    ls_order_header_in      = is_sales_order_internal-order_header_in.
    ls_order_header_inx     = is_sales_order_internal-order_header_inx.
    lt_return_messages      = is_sales_order_internal-return_messages.
    lt_order_items_in       = is_sales_order_internal-order_items_in.
    lt_order_items_inx      = is_sales_order_internal-order_items_inx.
    lt_order_partners       = is_sales_order_internal-order_partners.
    lt_order_schedules_in   = is_sales_order_internal-order_schedules_in.
    lt_order_schedules_inx  = is_sales_order_internal-order_schedules_inx.
    lt_order_conditions_in  = is_sales_order_internal-order_conditions_in.
    lt_order_conditions_inx = is_sales_order_internal-order_conditions_inx.
    lt_order_cfgs_ref       = is_sales_order_internal-order_cfgs_ref.
    lt_order_cfgs_inst      = is_sales_order_internal-order_cfgs_inst.
    lt_order_cfgs_part_of   = is_sales_order_internal-order_cfgs_part_of.
    lt_order_cfgs_value     = is_sales_order_internal-order_cfgs_value.
    lt_order_cfgs_blob      = is_sales_order_internal-order_cfgs_blob.
    lt_order_cfgs_vk        = is_sales_order_internal-order_cfgs_vk.
    lt_order_cfgs_refinst   = is_sales_order_internal-order_cfgs_refinst.
    lt_order_ccard          = is_sales_order_internal-order_ccard.
    lt_order_text           = is_sales_order_internal-order_text.
    lt_order_keys           = is_sales_order_internal-order_keys.
    lt_extensionin          = is_sales_order_internal-extensionin.
    lt_partneraddresses     = is_sales_order_internal-partneraddresses.
    lt_extensionex          = is_sales_order_internal-extensionex.

    CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
*      DESTINATION 'NONE'
      EXPORTING order_header_in      = ls_order_header_in
                order_header_inx     = ls_order_header_inx
      IMPORTING salesdocument        = lv_created_sales_order_no
      TABLES    return               = lt_return_messages
                order_items_in       = lt_order_items_in
                order_items_inx      = lt_order_items_inx
                order_partners       = lt_order_partners
                order_schedules_in   = lt_order_schedules_in
                order_schedules_inx  = lt_order_schedules_inx
                order_conditions_in  = lt_order_conditions_in
                order_conditions_inx = lt_order_conditions_inx
                order_cfgs_ref       = lt_order_cfgs_ref
                order_cfgs_inst      = lt_order_cfgs_inst
                order_cfgs_part_of   = lt_order_cfgs_part_of
                order_cfgs_value     = lt_order_cfgs_value
                order_cfgs_blob      = lt_order_cfgs_blob
                order_cfgs_vk        = lt_order_cfgs_vk
                order_cfgs_refinst   = lt_order_cfgs_refinst
                order_ccard          = lt_order_ccard
                order_text           = lt_order_text
                order_keys           = lt_order_keys
                extensionin          = lt_extensionin
                partneraddresses     = lt_partneraddresses
                extensionex          = lt_extensionex.

    LOOP AT lt_return_messages TRANSPORTING NO FIELDS WHERE type CA wmegc_severity_eax.
    ENDLOOP.

    IF sy-subrc = 0.
      " Error occurred during sales order creation
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      " Sales order creation successful
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING wait = abap_true.
      rv_created_sales_order_no = lv_created_sales_order_no.
    ENDIF.
  ENDMETHOD.

  METHOD _map_request_to_internal.
    CLEAR rs_internal.

    " Header mapping with dynamic X fill
    rs_internal-order_header_in = is_request-order_header_in.
    _fill_x_structure_dynamic( EXPORTING is_source = rs_internal-order_header_in
                               CHANGING  cs_target = rs_internal-order_header_inx ).

    " Items mapping
    rs_internal-order_items_in = is_request-order_items_in.
    _fill_x_table_dynamic( EXPORTING it_source = rs_internal-order_items_in
                           CHANGING  ct_target = rs_internal-order_items_inx ).

    " Partners
    rs_internal-order_partners     = is_request-order_partners.

    " Schedules
    rs_internal-order_schedules_in = is_request-order_schedules_in.
    _fill_x_table_dynamic( EXPORTING it_source = rs_internal-order_schedules_in
                           CHANGING  ct_target = rs_internal-order_schedules_inx ).

    " Conditions
    rs_internal-order_conditions_in = is_request-order_conditions_in.
    _fill_x_table_dynamic( EXPORTING it_source = rs_internal-order_conditions_in
                           CHANGING  ct_target = rs_internal-order_conditions_inx ).

    " Configuration references
    rs_internal-order_cfgs_ref     = is_request-order_cfgs_ref.

    " Configuration: Instances
    rs_internal-order_cfgs_inst    = is_request-order_cfgs_inst.

    " Configuration: Part-of Specifications
    rs_internal-order_cfgs_part_of = is_request-order_cfgs_part_of.

    " Configuration: Characteristic Values
    rs_internal-order_cfgs_value   = is_request-order_cfgs_value.

    " Configuration: BLOB Internal Data
    rs_internal-order_cfgs_blob    = is_request-order_cfgs_blob.

    " Configuration: Variant Condition Key
    rs_internal-order_cfgs_vk      = is_request-order_cfgs_vk.

    " Configuration: Reference Item / Instance
    rs_internal-order_cfgs_refinst = is_request-order_cfgs_refinst.

    " Credit Card Data
    rs_internal-order_ccard        = is_request-order_ccard.

    " Texts
    rs_internal-order_text         = is_request-order_text.

    " Output Table of Reference Keys
    rs_internal-order_keys         = is_request-order_keys.

    " Customer Enhancement for VBAK, VBAP, VBEP
    rs_internal-extensionin        = is_request-extensionin.

    " BAPI Reference Structure for Addresses (Org./Company)
    rs_internal-partneraddresses   = is_request-partneraddresses.

    " Reference Structure for BAPI Parameters ExtensionIn/ExtensionOut
    rs_internal-extensionex        = is_request-extensionex.
  ENDMETHOD.

  METHOD _fill_x_structure_dynamic.
    " Dynamically fill 'X' fields for structure when its target field has a value

    FIELD-SYMBOLS <fs_field>   TYPE any.
    FIELD-SYMBOLS <fs_x_field> TYPE any.

    DATA(lo_structuct_descr) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( is_source ) ).

    LOOP AT lo_structuct_descr->get_components( ) INTO DATA(ls_comp).

      ASSIGN COMPONENT ls_comp-name OF STRUCTURE is_source TO <fs_field>.
      ASSIGN COMPONENT ls_comp-name OF STRUCTURE cs_target TO <fs_x_field>.

      IF sy-subrc = 0 AND <fs_field> IS ASSIGNED AND <fs_x_field> IS ASSIGNED.
        " Copy itm_number field directly
        IF ls_comp-name = 'ITM_NUMBER'.
          <fs_x_field> = <fs_field>.

        " Set 'X' for fields that have values
        ELSEIF <fs_field> IS NOT INITIAL.
          <fs_x_field> = 'X'.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD _fill_x_table_dynamic.
    " Dynamically fill 'X' fields for internal tables

    DATA lo_table_descr TYPE REF TO cl_abap_tabledescr.
    DATA lo_line_descr  TYPE REF TO cl_abap_structdescr.
    DATA lo_data        TYPE REF TO data.

    FIELD-SYMBOLS <ls_source> TYPE any.
    FIELD-SYMBOLS <ls_target> TYPE any.

    " Get the table line type
    lo_table_descr ?= cl_abap_tabledescr=>describe_by_data( ct_target ).
    lo_line_descr ?= CAST cl_abap_structdescr( lo_table_descr->get_table_line_type( ) ).

    LOOP AT it_source ASSIGNING <ls_source>.
      " Create a new line dynamically
      CREATE DATA lo_data TYPE HANDLE lo_line_descr.
      ASSIGN lo_data->* TO <ls_target>.

      IF <ls_target> IS ASSIGNED.
        _fill_x_structure_dynamic( EXPORTING is_source = <ls_source>
                                   CHANGING  cs_target = <ls_target> ).
        INSERT <ls_target> INTO TABLE ct_target.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
