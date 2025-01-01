<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="homepage.aspx.vb" Inherits="ColorsHomeTask.homepage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
    <style>
         body { direction: rtl; }
        .table-container { 
            margin: 20px;
            height: 275px;
        }
        .colorTable { width: 100%; border-collapse: collapse; }
        .colorTable th, .colorTable td { 
            padding: 8px; 
            border: 1px solid #ddd; 
            text-align:center; 
        }
         .Div { 
            margin-bottom: 10px;
            display: flex;
            align-items: center;
        }
        .Div label {
            width: 120px;
            text-align: center;
        }
        .exist{
         margin-right:10px   ;
        }
        .colorName{ margin-right:10px; }
        .sortable-row { cursor: move; }
        #colorForm {
            border: 1px solid green;
            background: #f8f8f8;
            padding: 20px;
            border-radius: 5px;
            margin-top: 20px;
            width : 500px;
        }
        .buttons{
            width: 120px;
            text-align: center;
        }
        .colorList{
            text-align:center;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <h2>טבלת צבעים</h2>
            <div class="table-container">
                <table class="colorTable">
                <thead>
                     <tr>                
                        <th style="width: 20%">תיאור</th>
                        <th style="width: 20%">מחיר</th>
                        <th style="width: 20%">צבע</th>
                        <th style="width: 20%">סדר</th>
                        <th style="width: 20%">פעולות</th>
                    </tr>
                </thead>
                <tbody id="colorsList" class="sortable">
                </tbody>
                </table>
           </div>    
                <br/>
                <br/>
                <div id ="colorForm">
                    <div class ="Div">
                        <label class="required">שם הצבע:</label>
                        <input type="text" id="colorName" />
                        <input type="color" id="colorCode" />
                    </div>
                    <div class="Div">
                        <label class="required">מחיר:</label>
                        <input type="number" id="price" min="0" />
                    </div>
                    <div class="Div">
                        <label>סדר הצגה:</label>
                        <input type="number" id="displayOrder" min="1" />
                    </div>
                     <div class="Div">
                        <label>האם במלאי:</label>
                        <input type="checkbox" id="exist" />
                    </div>
                    <div class="buttons">
                        <button type="button" class="btn-new-color" onclick="newColor()">חדש</button>
                        <button type="button" class="btn-cancel" onclick="updateRow()">עדכן</button>
                    </div>
                </div>
        </div>
            
    </form>

    <script>
      
        $(document).ready(function () {
            //first when the program begin I get all Colors values and put in a table. 
            loadColors();

            //Here I handle the whole bonus issue of the client-side exercise
            $("#colorsList").sortable({
                update: function (event, ui) {
                    $('.sortable-row').each(function (index) {
                        var orders = [];
                        orders.push({
                            ColorId: $(this).data('id'),
                            DisplayOrder: index + 1
                        });

                        $.ajax({
                            url: 'homepage.aspx/UpdateDisplayOrder',
                            type: 'POST',
                            data: JSON.stringify({ orders: orders }),
                            contentType: 'application/json',
                            dataType: 'json',
                            success: function () {
                                loadColors();
                            }
                        });

                    });
                    
                }
            })
        });
        
     
        //function to get all colors from database and to put them in a table.
        function loadColors() {
            
            $.ajax({
                url: 'homepage.aspx/GetColors',
                type: 'POST',
                contentType: 'application/json',
                success: function (res) {
                    let colors = res.d;
                    let html = '';
                    console.log(colors);
                    for (let i = 0; i < colors.length; i++) {
                        html += createNewRowInTable(colors[i]);
                    }
                    $('#colorsList').html(html);
                }
            })
        }

        //function to add a row to table
        function createNewRowInTable(row) {

            return '<tr class="sortable-row" data-id="' + row.colorID + '">' +
                '<td>' + row.colorName + '</td>' +
                '<td>' + row.price + '</td>' +
                '<td style = "background-color: ' + row.colorCode + '";></td>' +
                '<td>' + row.displayOrder + '</td>' +
                '<td>' +
                '<button onclick="editRow(' + row.colorID +')">ערוך</button>' +
                '<button onclick="deleteRow(' + row.colorID +')">מחק</button>' +
                '</td></tr>';

        }
        //function to update a row in table
        function updateRow() {

            //got which row to update from local storage
            let idColor = window.localStorage.getItem("idToChange");

            if (idColor === 0) {
                alert("אתה צריך להחליט איזה צבע לערוך");
                return;
            }

            if ($('#price').val() <= 0) {
                alert("מחיר הצבע חייב להיות חיובי. שנה את המחיר!");
                return;
            }

            let dataObject = {
                colorId: idColor,
                colorName: $('#colorName').val(),
                colorCode: $('#colorCode').val(),
                price: $('#price').val(),
                displayOrder: $('#displayOrder').val()
            }
            $.ajax({
                url: 'homepage.aspx/UpdateColor',
                type: 'POST',
                data: JSON.stringify({ colorItem: dataObject }),
                contentType: 'application/json',
                success: function () {
                    loadColors();
                }
            })
        }

        //function after a user press on edit button
        function editRow(colorId) {

            //save which row to update in local storage
            window.localStorage.setItem("idToChange", colorId);
           
        }

        // function to add a new color to table and to database
        function newColor() {
            if ($('#exist').is(':checked')) {
                alert("אי אפשר להכניס צבע חדש אם הוא כבר קיים. סמן לא במלאי!");
                return;
            }
         
            if ($('#price').val() <= 0) {
                alert("מחיר הצבע חייב להיות חיובי. שנה את המחיר!");
                return;
            }
           
            let dataObject = {
                colorId:0,
                colorName: $('#colorName').val(),
                colorCode: $('#colorCode').val(),
                price: $('#price').val(),
                displayOrder: $('#displayOrder').val()

            };
            $.ajax({
                url: 'homepage.aspx/SaveColor',
                type: 'POST',
                data: JSON.stringify({ colorItem: dataObject }),
                contentType: 'application/json',
                success: function () {
                    loadColors();
                }
            })
        }

        //function for delete row from table and from database
        function deleteRow(colorId) {
            $.ajax({
                url: 'homepage.aspx/DeleteColor',
                type: 'POST',
                data: JSON.stringify({ colorId: colorId }),
                contentType: 'application/json',
                success: function () {
                    loadColors();
                }
            })
        }
    </script>
</body>
</html>
