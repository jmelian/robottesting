*** Settings ***
Library           String
Library           Collections
Library           RequestsLibrary
Library           OperatingSystem

*** Variables ***
${admin_user}=   Admin
${admin_pass}=   Admin
${test_user}=    testuser
${test_pass}=    testpass
${test_email}=    javier.melian@atos.net
${test_vnfd_pkg_bad}=    ./packages/cirros_vnf.tar.gz
${test_vnfd_pkg_ok}=    ./packages/hackfest_1_vnfd_fixed.tar.gz
${test_nsd_pkg_bad}=    ./packages/cirros_2vnf_ns.tar.gz
${test_nsd_pkg_ok}=    ./packages/hackfest_1_nsd_fixed.tar.gz
${test_experiment_bad}=   ./packages/exp.json
${test_experiment_ok}=   ./packages/exp_fixed.json
${dispatcher_URL}=   https://192.168.33.112:8082


*** Keywords ***
Create Multi Part
    [Arguments]  ${addTo}  ${partName}  ${filePath}  ${contentType}=${None}  ${content}=${None}
    ${fileData}=  Run Keyword If  '''${content}''' != '''${None}'''  Set Variable  ${content}
    ...            ELSE  Get Binary File  ${filePath}
    ${fileDir}  ${fileName}=  Split Path  ${filePath}
    ${partData}=  Create List  ${fileName}  ${fileData}  ${contentType}
    Set To Dictionary  ${addTo}  ${partName}=${partData}

*** Test Cases ***

#Register New User
#    # Request preparation
#    ${headers}=   create dictionary   Content-Type=application/x-www-form-urlencoded
#    ${params}=   create dictionary   username=${test_user}    email=${test_email}   password=${test_pass}
#    ${false}=    Convert To Boolean    False
#    Create Session  alias=Dispatcher  url=${dispatcher_URL}   headers=${headers}   verify=${false}
#
#    # Request
#    ${resp}=   Post Request  Dispatcher   /auth/register   data=${params}
#
#    # VALIDATIONS
#    #Should Be Equal As Strings  ${resp.json()['transaction']['status']}  success
#    Should Be Equal As Strings  ${resp.status_code}  200
#
#    # Output
#    log to console   ${resp}
#    log   ${resp.json()}
#

#Validate User
#    # Request preparation
#    ${headers}=   create dictionary   Content-Type=application/json  Authorization=Basic ABCDEF==
#    ${auth}=  Create List  ${admin_user}  ${admin_pass}
#    ${false}=    Convert To Boolean    False
#    Create Session  alias=Dispatcher  url=${dispatcher_URL}  headers=${headers}  auth=${auth}   verify=${false}
#
#    # Request
#    ${resp}=   Put Request  Dispatcher   /auth/validate_user/${test_user}
#    ${resp_body}=    convert to string   ${resp.content}
#
#    # VALIDATIONS
#    Should Be Equal As Strings  ${resp.status_code}  200
#    should contain   ${resp.json()}    Changes applied
#
#    # Output
#    log to console   ${resp}
#    log   ${resp.json()}
#

#Show Users
#    # Request preparation
#    ${headers}=   create dictionary   Content-Type=application/json  Authorization=Basic ABCDEF==
#    ${auth}=  Create List  ${admin_user}  ${admin_pass}
#    ${false}=    Convert To Boolean    False
#    Create Session  alias=Dispatcher  url=${dispatcher_URL}  headers=${headers}  auth=${auth}   verify=${false}
#
#    # Request
#    ${resp}=   Get Request  Dispatcher   /auth/show_users
#
#    # VALIDATIONS
#    Should Be Equal As Strings  ${resp.status_code}  200
#
#    # Output
#    log to console   ${resp}
#    log   ${resp.json()}
#

Get User Token
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



Post Faulty VNFD (Token Auth)
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


Post VNFD (Token Auth)
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

#Get VNFD list (Token Auth)
#    # Request preparation
#    ${headers}=   create dictionary   Content-Type=application/json  Authorization=${token}
#    ${false}=    Convert To Boolean    False
#    Create Session  alias=Dispatcher  url=${dispatcher_URL}  headers=${headers}   verify=${false}
#
#    # Request
#    ${resp}=  Get Request  Dispatcher   /mano/vnfd
#
#    # VALIDATIONS
#    log   ${resp.json()}
#    Should Be Equal As Strings  ${resp.status_code}  200
#
#Get VNFD list (Basic Auth)
#    # Request preparation
#    ${headers}=   create dictionary   Content-Type=application/json   Authorization=Basic ABCDEF==
#    ${auth}=  Create List   ${test_user}   ${test_pass}
#    ${false}=    Convert To Boolean    False
#    Create Session  alias=Dispatcher  url=${dispatcher_URL}  headers=${headers}  auth=${auth}   verify=${false}
#
#    # Request
#    ${resp}=  Get Request  Dispatcher   /mano/vnfd
#
#    # VALIDATIONS
#    log   ${resp.json()}
#    Should Be Equal As Strings  ${resp.status_code}  200


