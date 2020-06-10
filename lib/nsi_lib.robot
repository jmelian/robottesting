#   Copyright 2020 Atos
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

*** Settings ***
Library           Collections


*** Variables ***
${success_return_code}   0
${slice_launch_max_wait_time}   5min
${slice_launch_pol_time}   30sec
${slice_delete_max_wait_time}   1min
${slice_delete_pol_time}   15sec

*** Keywords ***
Create Network Slice
    [Arguments]   ${nst}   ${vim_name}   ${slice_name}   ${slice_config}   ${publickey}

    ${config_attr}   Set Variable If   '${slice_config}'!='${EMPTY}'   --config '${slice_config}'   \
    ${sshkeys_attr}   Set Variable If   '${publickey}'!='${EMPTY}'   --ssh_keys ${publickey}   \

    ${nsi_id}=   Instantiate Network Slice   ${slice_name}   ${nst}   ${vim_name}   ${config_attr} #${sshkeys_attr}
    log   ${nsi_id}

    WAIT UNTIL KEYWORD SUCCEEDS   ${slice_launch_max_wait_time}   ${slice_launch_pol_time}   Check For Network Slice Instance To Configured   ${slice_name}
    Check For Network Slice Instance For Failure   ${slice_name}
    [Return]  ${nsi_id}

Instantiate Network Slice
    [Arguments]   ${slice_name}   ${nst}   ${vim_name}   ${slice_extra_args}

    ${rc}   ${stdout}=   Run and Return RC and Output   osm nsi-create --nsi_name ${slice_name} --nst_name ${nst} --vim_account ${vim_name} ${slice_extra_args}
    log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    [Return]  ${stdout}


Get Slice Ns List
    [Arguments]   ${slice_name}

    Should Not Be Empty   ${slice_name}
    
    @{ns_list_string}=   Run and Return RC and Output   osm ns-list | grep ${slice_name} | awk '{print $4}' 2>&1
    # Returns a String of ns_id and needs to be converted into a list
    @{ns_list} =  Split String    ${ns_list_string}[1]
    Log List    ${ns_list}
    [Return]  @{ns_list}
    
Get Slice Ns List Except One
    [Arguments]   ${slice_name}   ${exception_ns}

    Should Not Be Empty   ${slice_name}
    Should Not Be Empty   ${exception_ns}
    
    @{ns_list_string}=   Run and Return RC and Output   osm ns-list | grep ${slice_name} | awk '!/${exception_ns}/' | awk '{print $4}' 2>&1
    # Returns a String of ns_id and needs to be converted into a list
    @{ns_list} =  Split String    ${ns_list_string}[1]
    Log List    ${ns_list}
    [Return]  @{ns_list}
    
Get Slice Ns Count
    [Arguments]   ${slice_name}

    Should Not Be Empty   ${slice_name}
    
    ${rc}   ${stdout}=   Run and Return RC and Output   osm ns-list | grep ${slice_name} | wc -l 2>&1
    log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    [Return]  ${stdout}


Get Slice Vnf Ip Addresses
    [Arguments]   ${slice_name}

    # Get all the ns_id in the slice except the middle one
    @{slice_ns_list}  Get Slice Ns List   ${slice_name}
    log many   @{slice_ns_list}
    @{temp_list}=    Create List
    # For each ns_id in the list, get all the vnf_id and their IP addresses
    FOR   ${ns_id}   IN   @{slice_ns_list}
        log   ${ns_id}
        @{vnf_id_list}   Get Ns Vnf List   ${ns_id}
        # For each vnf_id in the list, get all its IP addresses
        @{ns_ip_list}   Get Ns Ip List   @{vnf_id_list}
        @{temp_list}=   Combine Lists   ${temp_list}    ${ns_ip_list}
    END
    Log List   ${temp_list}
    [Return]   @{temp_list}


Check For Network Slice Instance To Configured
    [Arguments]  ${slice_name}

    ${rc}   ${stdout}=   Run and Return RC and Output   osm nsi-list --filter name="${slice_name}"
    log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    Should Contain Any   ${stdout}   READY   BROKEN	configured

Check For Network Slice Instance For Failure
    [Arguments]  ${slice_name}

    ${rc}   ${stdout}=   Run and Return RC and Output   osm nsi-list --filter name="${slice_name}"
    log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    Should Not Contain   ${stdout}   BROKEN

Check For Network Slice Instance To Be Deleted
    [Arguments]  ${slice_name}

    ${rc}   ${stdout}=   Run and Return RC and Output   osm nsi-list | awk '{print $2}' | grep ${slice_name}
    Should Not Be Equal As Strings   ${stdout}   ${slice_name}

Delete NSI
    [Documentation]  Delete Network Slice Instance (NSI)
    [Arguments]  ${slice_name}

    ${rc}   ${stdout}=   Run and Return RC and Output   osm nsi-delete ${slice_name}
    log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}

    WAIT UNTIL KEYWORD SUCCEEDS  ${slice_delete_max_wait_time}   ${slice_delete_pol_time}   Check For Network Slice Instance To Be Deleted   ${slice_name}
