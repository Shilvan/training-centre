import java.sql.*;
import java.util.Scanner;

public class JavaApp1 {
    private static final Scanner S = new Scanner(System.in);

    private static Connection c = null;

    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            c = DriverManager.getConnection("jdbc:mysql://localhost:3306/trainingCentre", "shilvan", "mypassword"); // ToDo : Specify Parameters !

            String choice = "";

            do {
                System.out.println("-- MAIN MENU --");
                System.out.println("1 - Browse ResultSet");
                System.out.println("2 - Invoke Procedure");
                System.out.println("Q - Quit");
                System.out.print("Pick : ");

                choice = S.next().toUpperCase();

                switch (choice) {
                    case "1" : {
                        browseResultSet();
                        break;
                    }
                    case "2" : {
                        invokeProcedure();
                        break;
                    }
                }
            } while (!choice.equals("Q"));

            c.close();

            System.out.println("Bye Bye :)");
        }
        catch (Exception e) {
            System.err.println(e.getMessage());
        }
    }

    private static void browseResultSet() throws Exception {
        
    	
    	try {
    		Statement s = c.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
    		ResultSet rs = s.executeQuery("SELECT module.code, module.name, session.date\r\n"
    				+ "	FROM session INNER JOIN module ON session.moduleCode = module.code \r\n"
    				+ "	WHERE YEAR(session.date) = (YEAR(CURDATE()) + 1) AND session.room IS NULL \r\n"
    				+ "	ORDER BY session.date ASC;");
    		ResultSetMetaData rsmd = rs.getMetaData();
    		int columnsNumber = rsmd.getColumnCount();
    		while (rs.next()) {
    			System.out.print("*");
    		    for (int i = 1; i <= columnsNumber; i++) {
    		        if (i > 1) System.out.print(", ");
    		        String columnValue = rs.getString(i);
    		        System.out.print(rsmd.getColumnName(i) +": "+columnValue);
    		    }
    		    System.out.println("");
    		}
    		
    	}
    	catch (Exception e) {
   		 System.err.println(e.getMessage());
   	 	}
    }

    private static void invokeProcedure() throws Exception {
    	System.out.print("----> Provide Course Code: ");
    	String course = S.next();
    	System.out.print("----> Provide Course Date YYYY-MM-DD: ");
    	String date = S.next();
    	
    	 try {
             Statement s = c.createStatement();
             ResultSet rs = s.executeQuery("CALL scheduleModules('"+course +"', '" + date +"');");
             System.out.println("*Scheduling course's modules");
         }
    	 catch (Exception e) {
    		 System.err.println(e.getMessage());
    	 }
    }
}
