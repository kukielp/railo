package railo.runtime.functions.file;

import railo.runtime.PageContext;
import railo.runtime.exp.PageException;
import railo.runtime.security.SecurityManager;
import railo.runtime.tag.FileTag;
import railo.runtime.type.Array;

public class FileUploadAll {

	public static Array call(PageContext pc, String destination) throws PageException {
		return call(pc, destination, null, null, null, null, null);
	}
	public static Array call(PageContext pc, String destination,String accept) throws PageException {
		return call(pc, destination, accept, null, null, null,null);
	}
	public static Array call(PageContext pc, String destination,String accept, String nameConflict) throws PageException {
		return call(pc, destination, accept, nameConflict, null, null,null);
	}
	public static Array call(PageContext pc, String destination,String accept, String nameConflict,String mode) throws PageException {
		return call(pc, destination, accept, nameConflict, mode, null,null);
	}
	public static Array call(PageContext pc, String destination,String accept, String nameConflict,String mode,String attributes) throws PageException {
		return call(pc, destination, accept, nameConflict, mode, attributes,null);
	}
	
	public static Array call(PageContext pc, String destination,String accept, String nameConflict,String mode,String attributes,Object acl) throws PageException {
	    SecurityManager securityManager = pc.getConfig().getSecurityManager();
		int nc = FileTag.toNameconflict(nameConflict);
	    int m=FileTag.toMode(mode);
	    
	    return FileTag.actionUploadAll(pc,securityManager,destination, nc, accept, m, attributes, acl, null);
	}
}
