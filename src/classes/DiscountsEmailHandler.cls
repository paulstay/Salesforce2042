global class DiscountsEmailHandler  extends InboundEmailHandler implements Messaging.InboundEmailHandler {
    
    global override Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) { 
        this.caseRecType = 'Discounts';
        this.queueName = 'Discounts';
        Messaging.InboundEmail.Header hd = new Messaging.InboundEmail.Header();
        hd.name = 'caseFeedCheck';
        hd.value = (test.isRunningTest() ? 'false' : 'true');
        email.Headers.add(hd);
        return super.handleInboundEmail(email, envelope);
    }
    
}