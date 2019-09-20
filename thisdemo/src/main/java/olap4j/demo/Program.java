package olap4j.demo;
import groovy.sql.DataSet;
import org.olap4j.*;

import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.List;

public class Program {
    public static void main(String[] args) throws SQLException, ClassNotFoundException {
        Class.forName("org.olap4j.driver.xmla.XmlaOlap4jDriver");
        OlapConnection con = (OlapConnection) DriverManager.getConnection("jdbc:xmla:Server=" +
                "http://10.86.65.20/olap/msmdpump.dll;Catalog=MarketingAssistantDW");
        OlapWrapper wrapper = (OlapWrapper) con;
        OlapConnection olapConnection = wrapper.unwrap(OlapConnection.class);
        OlapStatement stmt = olapConnection.createStatement();

        CellSet cellSet = stmt.executeOlapQuery(" SELECT " +
                "NON EMPTY { [Measures].[经销商累计销量] } ON COLUMNS, " +
                "NON EMPTY { ([省份城市经销商].[Show Name].[Show Name].ALLMEMBERS ) } ON ROWS " +
                "FROM [VehicleSales]");
        List<CellSetAxis> cellSetAxisList= cellSet.getAxes();
        System.out.println(cellSetAxisList.size());
//        DataSet ds = new DataSet();
//        for (Position rowPos : cellSet.getAxes().get(1)) {
//            ds.addRow();
//            for (Position colPos : cellSet.getAxes().get(0)) {
//                test += Integer.toString(rowPos.getOrdinal()) + " : " + Integer.toString(colPos.getOrdinal());
//                Cell cell = cellSet.getCell(colPos, rowPos);
//                test += "Value: " + cell.getFormattedValue() + "<br />";
//                ds.addValue("column" + Integer.toString(colPos.getOrdinal()), cell.getFormattedValue());
//            }
//        }
    }
}
