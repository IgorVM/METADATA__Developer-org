public class Controller_PdfJs {
    
	public PageReference GenReport() {
 
        Attachment att = new Attachment(); 
        PageReference pdf = Page.PdfGenerator;
        //PageReference vfreport = new PageReference('/apex/TestPdfJs');
        //vfreport.getparameters().put('id','00324000004VQXj');
        pdf.getParameters().put('id','00324000004VQXj');
        //Blob bodyBlob=Blob.valueOf('%PDF- Unit Test Attachment Body');
        //att.body=bodyBlob;
        att.Body = pdf.getContent();
        string rpttype = 'Move';
        
        string action='Executed';
        att.name = 'IP_'+system.now().format('yyyy_MM_dd_hh_mm_ss')+'.pdf';
        att.parentid='00324000004VQXj';
        List<Attachment> listAtt = [Select name, parentId, body from Attachment where parentId = '00324000004VQXj' And name = 'CustSign.jpg'];
        if(listAtt.size() > 0){
            String bb = EncodingUtil.base64Encode(att.Body);
            String nbb = EncodingUtil.base64Encode(listAtt[0].body);
            String result = bb + nbb;
            att.Body = Blob.valueOf(result);
        }
        try{
            insert att;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Report Generated'));
        }catch(Exception err){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Gen Report Error '+err.getMessage()));
            return null;
        }
      return null;
   }
}