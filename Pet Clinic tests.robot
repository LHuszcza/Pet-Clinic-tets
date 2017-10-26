*** Settings ***
Library           Selenium2Library
Library           String
Library           DateTime
Library           BuiltIn
Library           FakerLibrary

*** Variables ***
${Browser}        chrome
${HOST}           http://localhost:8080
${Title}          Welcome
${Delay}          5s
${Error_msg}      Something happened...
${First_name}     anna
${address}        wawelska
${city}           warsaw
${telephone}      501987456
@{pet_type}       bird    cat    dog    hamster    lizard    snake
${visit_date}     2018/01/26    # some future date

*** Test Cases ***
Pet Clinic menu navigation
    Open Pet Clinic
    open Eror page
    back to Homepage
    open Find Owners site
    open Veterinarians
    open help
    Log    Pet Clinic main page works properly    WARN
    [Teardown]    Close All Browsers

Add visit for Pet - positive scenario
    ${Owner}    add owner
    add specific pet
    Click Link    Add Visit
    Location Should Contain    /visits/new
    Page Should Contain    New Visit
    Input Text    date    ${visit_date}
    Click Element    //html/body
    ${random_description}    Generate Random String    12    [LOWER]
    Input Text    description    ${random_description}
    Click Button    Add Visit
    Location Should Contain    /owners/
    Page Should Contain    Owner Information
    Page Should Contain    ${random_description}
    ${added_visit_date}    Convert Date    ${visit_date}    result_format=%Y-%m-%d
    Page Should Contain    ${added_visit_date}
    Log    New visit with future date added successfully    WARN
    [Teardown]    Close All Browsers

Add visit for Pet - negative scenario with past date added
    ${Owner}    add owner
    add specific pet
    Click Link    Add Visit
    Location Should Contain    /visits/new
    Page Should Contain    New Visit
    ${random_past_date}    Date    # returns date in format %Y-%m-%d
    ${past_date_valid_format}    Convert Date    ${random_past_date}    result_format=%Y/%m/%d    exclude_millis=yes
    Input Text    date    ${past_date_valid_format}
    Click Element    //html/body
    ${random_description}    Generate Random String    12    [LOWER]
    Input Text    description    ${random_description}
    Click Button    Add Visit
    Location Should Contain    /owners/
    Page Should Contain    Owner Information
    Page Should Contain    ${random_description}
    Page Should Contain    ${random_past_date}
    Log    It's possible to add new visit with past date    WARN
    [Teardown]    Close All Browsers

Edit pet's name
    ${Owner}    add owner
    add specific pet
    Click Link    Edit Pet
    Location Should Contain    /edit
    Page Should Contain    Pet
    ${random_pet_name}    Generate Random String    12    [UPPER]
    Input Text    name    ${random_pet_name}
    Log    Pet's new name ${random_pet_name}    WARN
    Click Button    Update Pet
    Location Should Contain    /owners/
    Page Should Contain    Owner Information
    Page Should Contain    ${random_pet_name}
    Log    Pet updated successfully    WARN
    [Teardown]    Close All Browsers

Find Owner case sensitivity
    ${Owner_uppercase}    add owner
    ${Owner_lowercase}    Convert To Lowercase    ${Owner_uppercase}
    ${owner_found}    find owners    ${Owner_lowercase}
    Run Keyword If    '${owner_found}' == 'True'    log    Find Owners case insensitive    WARN
    Run Keyword Unless    '${owner_found}' == 'True'    log    Find Owners case sensitive    WARN
    [Teardown]    Close All Browsers

Add Owner
    ${Owner}    add owner
    Log    Add Owner functionality works properly    WARN
    [Teardown]    Close All Browsers

Add new pets
    ${Owner}    add owner
    add all types of random pets
    [Teardown]    Close All Browsers

Verify Find Owner functionality
    ${Owner}    add owner
    ${owner_found}    find owners    ${Owner}
    Run Keyword If    '${owner_found}' == 'True'    log    Owners search works properly    WARN
    Run Keyword Unless    '${owner_found}' == 'True'    log    Owner couldn't be find    WARN
    [Teardown]    Close All Browsers

Update Owner if exists
    ${Owner}    add owner
    verify if exists and update owner    ${Owner}
    [Teardown]    Close All Browsers

Verify veterinarians xml
    open Veterinarians
    ${veterinarian}    Get Table Cell    xpath=//table[@class='table table-stripped']    -1    1    # -1 value returns last row
    ${vet_first_name}    Get Substring    ${veterinarian}    0    \    # veterinarian's first name
    ${vet_last_name}    Get Substring    ${veterinarian}    1    \    # veterinarian's last name
    Click Link    //*[text()='View as XML']
    Location Should Contain    /vets.xml
    Page Should Contain    ${vet_first_name}
    Page Should Contain    ${vet_last_name}
    Log    XML opens properly    WARN
    [Teardown]    Close All Browsers

verify atom feed
    open Veterinarians
    ${veterinarian}    Get Table Cell    xpath=//table[@class='table table-stripped']    -1    1    # -1 value returns last row
    Click Link    //*[text()='Subscribe to Atom feed']
    Location Should Contain    /vets.atom
    Page Should Contain    ${veterinarian}
    Log    Atom feed opens properly    WARN
    [Teardown]    Close All Browsers

*** Keywords ***
Open Pet Clinic
    open browser    ${HOST}/petclinic/    ${Browser}
    Location Should Contain    /petclinic/
    Maximize Browser Window
    Page Should Contain    Welcome

open Eror page
    Open Pet Clinic
    Click Link    //*[text()='Error']
    Location Should Contain    /oups.html
    Page Should Contain    ${Error_msg}

back to Homepage
    open Eror page
    Click Link    //*[text()='Home']
    Location Should Contain    /petclinic/
    Page Should Contain    Welcome
    Log    Home page opened properly    WARN

open Veterinarians
    Open Pet Clinic
    Click Link    //*[text()='Veterinarians']
    Location Should Contain    /vets.html
    Page Should Contain    Veterinarians
    Log    Veterinarians opened successfully    WARN

open Find Owners site
    Open Pet Clinic
    Click Link    //*[text()='Find owners']
    Location Should Contain    /owners/find.html
    Page Should Contain    Find Owners
    Log    Find Owners site opened properly    WARN

verify veterinarians xml
    open Veterinarians
    ${veterinarian}    Get Table Cell    xpath=//table[@class='table table-stripped']    -1    1    # -1 value returns last row
    ${vet_first_name}    Get Substring    ${veterinarian}    0    \    # veterinarian's first name
    ${vet_last_name}    Get Substring    ${veterinarian}    1    \    # veterinarian's last name
    Click Link    //*[text()='View as XML']
    Location Should Contain    /vets.xml
    Page Should Contain    ${vet_first_name}
    Page Should Contain    ${vet_last_name}
    Log    XML opens properly    WARN

verify atom feed
    open Veterinarians
    ${veterinarian}    Get Table Cell    xpath=//table[@class='table table-stripped']    -1    1    # -1 value returns last row
    Click Link    //*[text()='Subscribe to Atom feed']
    Location Should Contain    /vets.atom
    Page Should Contain    ${veterinarian}
    Log    Atom feed opens properly    WARN

add owner
    open browser    ${HOST}/petclinic/owners/find.html    ${Browser}
    Maximize Browser Window
    Wait Until Page Contains    Find Owners
    Click Link    Add Owner
    Location Should Contain    /owners/new
    Wait Until Page Contains    New \ Owner
    ${Last_name_random}    Generate Random String    12    [UPPER]
    ${First_name}    Generate Random String    12    [UPPER]
    ${address}    Generate Random String    12    [UPPER]
    ${city}    Generate Random String    12    [UPPER]
    ${telephone}    Generate Random String    10    [NUMBERS]
    Input Text    //*[@id="firstName" ]    ${First_name}
    Input Text    //*[@id="lastName"]    ${Last_name_random}
    Input Text    //*[@id="address"]    ${address}
    Input Text    //*[@id="city"]    ${city}
    Input Text    //*[@id="telephone"]    ${telephone}
    Click Button    //*[@id="add-owner-form"]/div[6]/button
    Page Should Contain    Owner Information
    Log     Owner ${Last_name_random} added    WARN
    Return From Keyword    ${Last_name_random}
    [Return]    ${Last_name_random}

add all types of random pets
    [Arguments]    ${pet_from_list}=0
    : FOR    ${ELEMENT}    IN    @{pet_type}
    \    Click Link    //*[text()='Add New Pet']
    \    Location Should Contain    pets/new.html
    \    ${pet_name}    Generate Random String    12    [UPPER]
    \    Input Text    name    ${pet_name}
    \    ${pet_birth_date}    Date    # returns date in format %Y-%m-%d
    \    ${valid_pet_birth_date}    Convert Date    ${pet_birth_date}    result_format=%Y/%m/%d    exclude_millis=yes
    \    Input Text    birthDate    ${valid_pet_birth_date}
    \    Click Element    //html/body
    \    Select From List    type    ${ELEMENT}
    \    Click Button    //*[text()='Add Pet']
    Log    Every type of pets added successfully    WARN

find owners
    [Arguments]    ${Owner}
    open Find Owners site
    Log    Looking for Owner ${Owner}    WARN
    Input Text    xpath=//*[@name='lastName']    ${Owner}
    Click Button    Find Owner
    Location Should Contain    /owners
    ${status}=    Run Keyword And Return Status    Page Should Contain    Owner Information
    Run Keyword If    '${status}' == 'True'    log    ${Owner} Found    WARN
    Run Keyword Unless    '${status}' == 'True'    log    ${Owner} has not been found    WARN
    Return From Keyword    ${status}
    [Return]    ${status}    # says if Owner exists

edit owner
    [Arguments]    ${Owner}
    Click Link    //*[text()='Edit Owner']
    Location Should Contain    /edit.html
    Page Should Contain Button    Update Owner
    ${Updated_Last_Name}=    Generate Random String    12    [UPPER]
    Input Text    //*[@id="lastName"]    ${Updated_Last_Name}
    Log    Owner's new name: ${Updated_Last_Name}    WARN
    Return From Keyword    ${Updated_Last_Name}
    [Return]    ${Updated_Last_Name}

update existing Owner
    [Arguments]    ${Owner}
    ${Updated}    edit owner    ${Owner}
    Click Button    Update Owner
    Location Should Contain    /owners/
    Page Should Contain    Owner Information
    find owners    ${Updated}
    log    Owner updated successfully    WARN

verify if exists and update owner
    [Arguments]    ${Owner}
    ${find_owner_result}=    find owners    ${Owner}
    Run Keyword If    '${find_owner_result}'=='True'    update existing Owner    ${Owner}
    ...    ELSE    owner doesn't exist

owner doesn't exist
    log    Can't update not existing Owner    WARN

add specific pet
    [Arguments]    ${name}=puppy    ${birth_date}=2017/08/01    ${type}=dog
    Click Link    //*[text()='Add New Pet']
    Location Should Contain    pets/new.html
    Input Text    name    ${name}
    Input Text    birthDate    ${birth_date}
    Click Element    //html/body
    Select From List    type    ${type}
    Click Button    //*[text()='Add Pet']
    Log    ${type} ${name} added    WARN

open help
    Open Pet Clinic
    Click Link    //*[text()='Help']
    Log    Help not available yet. Work in progress!!!    WARN
