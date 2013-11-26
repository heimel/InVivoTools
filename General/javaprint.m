function javaprint( filename, mimetype )      


% http://docs.oracle.com/javase/1.4.2/docs/api/javax/print/DocFlavor.INPUT_STREAM.html

import java.io.*;  
import javax.print.*;  
import javax.print.attribute.*;   
import javax.print.attribute.standard.*;   

if nargin<1 || isempty(filename)
    disp('JAVAPRINT: No filename supplied');
    return
end

if nargin<2
   [~,~,ext] = fileparts( filename );
   if isempty(ext)
       disp('JAVAPRINT: Unknown filetype');
       return
   end
   mimetype = ext(2:end);
end

switch mimetype
    case 'html'
        mimetype = 'text/html; charset=utf-16';
    case 'ps'
        mimetype = 'application/postscript';
    case 'pdf'
        mimetype = 'application/pdf';
    case 'txt'
        mimetype = 'text/plain; charset=us-ascii';
end

%mimetype = 'application/octet-stream'
%mimetype='application/vnd.hp-PCL'
disp(mimetype)

cd(getdesktopfolder)
psStream = FileInputStream(filename);  
psInFormat = DocFlavor(mimetype,'java.io.InputStream');  
myDoc = SimpleDoc(psStream, psInFormat, []);    
aset = HashPrintRequestAttributeSet();  
services = PrintServiceLookup.lookupPrintServices(psInFormat, aset);  


for i = 1:services.length
    svcName = char(services(i).toString());
    disp(['service found: ' svcName]);
    if ~isempty(findstr(svcName,'printer closest to me'))
        myPrinter = services(i);
        disp(['my printer found: ' char(svcName)]);
        break;
    end
end

defaultPrinter = services(1);
myPrinter = defaultPrinter;

if ~isempty(myPrinter)
    job = myPrinter.createPrintJob();
    job.print(myDoc, aset);
else
    disp('No printer found');
end
            
