<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notificate_somebody</fullName>
        <description>Notificate somebody</description>
        <protected>false</protected>
        <recipients>
            <recipient>ivm.ekb@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/NameContainsEmailTemplate</template>
    </alerts>
    <rules>
        <fullName>NameContains</fullName>
        <actions>
            <name>Notificate_somebody</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>myobj__c.Name</field>
            <operation>contains</operation>
            <value>and</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
