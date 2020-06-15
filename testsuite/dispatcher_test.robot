*** Settings ***
Library           String
Library           Collections
Library           RequestsLibrary
Library           OperatingSystem

*** Variables ***
# Credentials
${admin_user}=   Admin
${admin_pass}=   Admin
${test_user}=     %{TEST_USER}
${test_pass}=    %{TEST_PASS}
${test_email}=    %{TEST_EMAIL}
# Descriptors
${test_vnfd_pkg_bad}=    %{PACKAGES_DIR}/cirros_vnf.tar.gz
${test_vnfd_pkg_ok}=    %{PACKAGES_DIR}/hackfest_1_vnfd_fixed.tar.gz
${test_nsd_pkg_bad}=    %{PACKAGES_DIR}/cirros_2vnf_ns.tar.gz
${test_nsd_pkg_ok}=    %{PACKAGES_DIR}/hackfest_1_nsd_fixed.tar.gz
${test_nsd_id}=    hackfest_1_nsd

${test_experiment_bad}=   %{PACKAGES_DIR}/exp.json
${test_experiment_ok}=   %{PACKAGES_DIR}/exp_fixed.json
# VIM
${test_image_file}=   %{PACKAGES_DIR}/%{IMAGE}
${vim_name}=   %{VIM_NAME}


${dispatcher_URL}=   %{API_URL}


*** Keywords ***
Create Multi Part
    [Arguments]  ${addTo}  ${partName}  ${filePath}  ${contentType}=${None}  ${content}=${None}
    ${fileData}=  Run Keyword If  '''${content}''' != '''${None}'''  Set Variable  ${content}
    ...            ELSE  Get Binary File  ${filePath}
    ${fileDir}  ${fileName}=  Split Path  ${filePath}
    ${partData}=  Create List  ${fileName}  ${fileData}  ${contentType}
    Set To Dictionary  ${addTo}  ${partName}=${partData}

*** Test Cases ***

Register New User
    # Request preparation
    ${headers}=   create dictionary   Content-Type=application/x-www-form-urlencoded
    ${params}=   create dictionary   username=${test_user}    email=${test_email}   password=${test_pass}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}   headers=${headers}   verify=${false}

    # Request
    ${resp}=   Post Request  Dispatcher   /auth/register   data=${params}

    # VALIDATIONS
    #Should Be Equal As Strings  ${resp.json()['transaction']['status']}  success
    Should Be Equal As Strings  ${resp.status_code}  200

    # Output
    log to console   ${resp}
    log   ${resp.json()}


Validate User
    # Request preparation
    ${headers}=   create dictionary   Content-Type=application/json  Authorization=Basic ABCDEF==
    ${auth}=  Create List  ${admin_user}  ${admin_pass}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}  headers=${headers}  auth=${auth}   verify=${false}

    # Request
    ${resp}=   Put Request  Dispatcher   /auth/validate_user/${test_user}
    ${resp_body}=    convert to string   ${resp.content}

    # VALIDATIONS
    Should Be Equal As Strings  ${resp.status_code}  200
    should contain   ${resp.content}    Changes applied

    # Output
    log to console   ${resp}
    log   ${resp.json()}


Show Users
    # Request preparation
    ${headers}=   create dictionary   Content-Type=application/json  Authorization=Basic ABCDEF==
    ${auth}=  Create List  ${admin_user}  ${admin_pass}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}  headers=${headers}  auth=${auth}   verify=${false}

    # Request
    ${resp}=   Get Request  Dispatcher   /auth/show_users

    # VALIDATIONS
    Should Be Equal As Strings  ${resp.status_code}  200

    # Output
    log to console   ${resp}
    log   ${resp.json()}


Get User Token
    sleep  5s
    # Request preparation
    ${headers}=   create dictionary   Content-Type=application/json  Authorization=Basic ABCDEF==
    ${auth}=  Create List  ${test_user}  ${test_pass}
    #${auth}=  Create List  ${admin_user}  ${admin_pass}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}  headers=${headers}  auth=${auth}   verify=${false}

    # Request
    ${resp}=   Get Request  Dispatcher   /auth/get_token

    # VALIDATIONS
    Should Be Equal As Strings  ${resp.status_code}  200

    # Output preparation
    ${token_aux}=   catenate   Bearer   ${resp.json()['result']}

    # Output
    Set Suite Variable   ${token}   ${token_aux}
    Log   ${token}


List VIMs
    sleep  5s
    # Request preparation
    ${headers}=   create dictionary   Content-Type=application/json   Authorization=${token}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}  headers=${headers}   verify=${false}

    # Request
    ${resp}=  Get Request  Dispatcher   /mano/vims

    # VALIDATIONS
    #log   ${resp.json()}
    log to console   ${resp.content}
    Should Contain  ${resp.text}   ${vim_name}
    Should Be Equal As Strings  ${resp.status_code}  200


Upload Image VIM
    sleep  5s
    # Request preparation
    ${headers}=   create dictionary   Authorization=${token}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}   headers=${headers}   verify=${false}

    # Data
    &{data}=    Create Dictionary    vim_id=${vim_name}    container_format=bare
    ${file_data}=    Get Binary File    ${test_image_file}
    &{files}=    Create Dictionary    file=${file_data}

    ${resp}=    Post Request    Dispatcher   /mano/image   files=${files}    data=${data}

    # VALIDATIONS
    log to console   ${resp.content}
    #${error} =  Get From Dictionary  ${resp.json()}   error
    #Should Be Equal  ${error}   Some VNFs have invalid descriptors
    #Should Be Equal As Strings  ${resp.json()['error']}   Some VNFs have invalid descriptors
    Should Be Equal As Strings    ${resp.status_code}    201



Index Faulty VNFD (Token Auth)
    sleep  5s
    # Request preparation
    ${headers}=   create dictionary   Authorization=${token}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}   headers=${headers}   verify=${false}

    # Data
    &{data}=    Create Dictionary    visibility=True
    ${file_data}=    Get Binary File    ${test_vnfd_pkg_bad}
    &{files}=    Create Dictionary    file=${file_data}

    ${resp}=    Post Request    Dispatcher   /mano/vnfd    files=${files}    data=${data}

    # VALIDATIONS
    log   ${resp.json()}
    ${error} =  Get From Dictionary  ${resp.json()}   error
    Should Be Equal  ${error}   Some VNFs have invalid descriptors
    #Should Be Equal As Strings  ${resp.json()['error']}   Some VNFs have invalid descriptors
    Should Be Equal As Strings    ${resp.status_code}    400


Index VNFD (Token Auth)
    sleep  5s
    # Request preparation
    ${headers}=   create dictionary   Authorization=${token}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}   headers=${headers}   verify=${false}

    # Data
    &{data}=    Create Dictionary    visibility=True
    ${file_data}=    Get Binary File    ${test_vnfd_pkg_ok}
    &{files}=    Create Dictionary    file=${file_data}

    ${resp}=    Post Request    Dispatcher   /mano/vnfd    files=${files}    data=${data}

    # VALIDATIONS
    log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


Get VNFD list (Token Auth)
    sleep  5s
    # Request preparation
    ${headers}=   create dictionary   Content-Type=application/json  Authorization=${token}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}  headers=${headers}   verify=${false}

    # Request
    ${resp}=  Get Request  Dispatcher   /mano/vnfd

    # VALIDATIONS
    log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


Get VNFD list (Basic Auth)
    sleep  5s
    # Request preparation
    ${headers}=   create dictionary   Content-Type=application/json   Authorization=Basic ABCDEF==
    ${auth}=  Create List   ${test_user}   ${test_pass}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}  headers=${headers}  auth=${auth}   verify=${false}

    # Request
    ${resp}=  Get Request  Dispatcher   /mano/vnfd

    # VALIDATIONS
    log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


Index Faulty NSD (Token Auth)
    sleep  5s
    # Request preparation
    ${headers}=   create dictionary   Authorization=${token}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}   headers=${headers}   verify=${false}

    # Data
    &{data}=    Create Dictionary    visibility=True
    ${file_data}=    Get Binary File    ${test_nsd_pkg_bad}
    &{files}=    Create Dictionary    file=${file_data}

    ${resp}=    Post Request    Dispatcher   /mano/nsd    files=${files}    data=${data}

    # VALIDATIONS
    log   ${resp.json()}
    ${error} =  Get From Dictionary  ${resp.json()}   error
    #Should Be Equal  ${error}   Some VNFs have invalid descriptors
    #Should Be Equal As Strings  ${resp.json()['error']}   Some VNFs have invalid descriptors
    Should Be Equal As Strings    ${resp.status_code}    400


Index NSD (Token Auth)
    sleep  5s
    # Request preparation
    ${headers}=   create dictionary   Authorization=${token}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}   headers=${headers}   verify=${false}

    # Data
    &{data}=    Create Dictionary    visibility=True
    ${file_data}=    Get Binary File    ${test_nsd_pkg_ok}
    &{files}=    Create Dictionary    file=${file_data}

    ${resp}=    Post Request    Dispatcher   /mano/nsd    files=${files}    data=${data}

    # VALIDATIONS
    log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


Get NSD list (Token Auth)
    sleep  5s
    # Request preparation
    ${headers}=   create dictionary   Content-Type=application/json  Authorization=${token}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}  headers=${headers}   verify=${false}

    # Request
    ${resp}=  Get Request  Dispatcher   /mano/nsd

    # VALIDATIONS
    log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


Validate Bad Experiment Descriptor
    sleep  5s
    # Request preparation
    ${headers}=   create dictionary   Authorization=${token}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}   headers=${headers}   verify=${false}

    # Data
    ${file_data}=    Get File    ${test_experiment_bad}

    ${resp}=    Post Request    Dispatcher   /distributor/validate/ed    data=${file_data}

    # VALIDATIONS
    log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    400


Validate Experiment Descriptor
    sleep  5s
    # Request preparation
    ${headers}=   create dictionary   Authorization=${token}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}   headers=${headers}   verify=${false}

    # Data
    ${file_data}=    Get File    ${test_experiment_ok}
    ${resp}=    Post Request    Dispatcher   /distributor/validate/ed    data=${file_data}

    # VALIDATIONS
    log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


Delete NSD
    sleep  5s
    # Request preparation
    ${headers}=   create dictionary   Authorization=${token}
    ${false}=    Convert To Boolean    False
    Create Session  alias=Dispatcher  url=${dispatcher_URL}   headers=${headers}   verify=${false}

    # Data
    &{data}=    Create Dictionary    all=True

    ${resp}=    Delete Request    Dispatcher   /mano/nsd/${test_nsd_id}    data=${data}

    # VALIDATIONS
    log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


# Delete User
#     # Request preparation
#     ${headers}=   create dictionary   Content-Type=application/json  Authorization=Basic ABCDEF==
#     ${auth}=  Create List  ${test_user}  ${test_pass}
#     #${auth}=  Create List  ${admin_user}  ${admin_pass}
#     ${false}=    Convert To Boolean    False
#     Create Session  alias=Dispatcher  url=${dispatcher_URL}  headers=${headers}  auth=${auth}   verify=${false}

#     # Request
#     ${resp}=   Delete Request  Dispatcher   /auth/delete_user/${test_user}

#     # VALIDATIONS
#     Should Be Equal As Strings  ${resp.status_code}  200


# Drop Database
#     # Request preparation
#     ${headers}=   create dictionary   Content-Type=application/json  Authorization=Basic ABCDEF==
#     ${auth}=  Create List  ${test_user}  ${test_pass}
#     #${auth}=  Create List  ${admin_user}  ${admin_pass}
#     ${false}=    Convert To Boolean    False
#     Create Session  alias=Dispatcher  url=${dispatcher_URL}  headers=${headers}  auth=${auth}   verify=${false}

#     # Request
#     ${resp}=   Delete Request  Dispatcher   /auth/drop_db

#     # VALIDATIONS
#     Should Be Equal As Strings  ${resp.status_code}  200


