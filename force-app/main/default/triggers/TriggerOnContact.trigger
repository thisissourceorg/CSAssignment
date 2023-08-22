trigger TriggerOnContact on Contact (after insert, after update, after delete) 
{
    if(Trigger.IsAfter)
    {
        if(Trigger.IsInsert) 
        {
            TriggerOnContactHandler.countNumberOfContactsInAccount(Trigger.new,Trigger.oldMap);
        }
        if(Trigger.IsUpdate) 
        {
            TriggerOnContactHandler.countNumberOfContactsInAccount(Trigger.new,Trigger.oldMap);
        }
        if(Trigger.IsDelete) 
        {
            TriggerOnContactHandler.countNumberOfContactsInAccount(Trigger.new,Trigger.oldMap);
        }
    }
}