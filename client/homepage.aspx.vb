
Imports System.Data.SqlClient
Imports System.Web.Services

Public Class homepage
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub

    <System.Web.Services.WebMethod>
    Public Shared Function GetColors() As List(Of ColorItem)

        Dim colorsList As New List(Of ColorItem)
        Dim conStr As String = "server=.;database=ColorsHomeTaskDB;integrated security=SSPI"

        Using con As New SqlConnection(conStr)
            Using commend As New SqlCommand("select * From Colors ORDER BY DisplayOrder", con)
                con.Open()

                Using reader As SqlDataReader = commend.ExecuteReader()
                    While reader.Read()
                        colorsList.Add(New ColorItem With {
                            .colorID = Convert.ToInt32(reader("ColorID")),
                            .colorName = reader("ColorName"),
                            .colorCode = reader("ColorCode").ToString(),
                            .price = Convert.ToDecimal(reader("Price")),
                            .displayOrder = Convert.ToInt32(reader("DisplayOrder")),
                            .exist = Convert.ToBoolean(reader("Exist"))
                    })
                    End While
                End Using
            End Using

        End Using
        Return colorsList

    End Function

    <System.Web.Services.WebMethod>
    Public Shared Function SaveColor(colorItem As Object) As Boolean
        Console.WriteLine("In save color function")


        Dim conStr As String = "server=.;database=ColorsHomeTaskDB;integrated security=SSPI"
        Using con As New SqlConnection(conStr)
            Dim sql As String

            sql = "INSERT INTO Colors (ColorName, ColorCode, Price, DisplayOrder) VALUES (@ColorName, @ColorCode, @Price, @DisplayOrder)"

            Using cmd As New SqlCommand(sql, con)
                cmd.Parameters.Clear()
                cmd.Parameters.AddWithValue("@ColorName", colorItem("colorName"))
                cmd.Parameters.AddWithValue("@ColorCode", colorItem("colorCode"))
                cmd.Parameters.AddWithValue("@Price", colorItem("price"))
                cmd.Parameters.AddWithValue("@DisplayOrder", colorItem("displayOrder"))

                con.Open()
                Return cmd.ExecuteNonQuery() > 0
            End Using
        End Using

    End Function

    <System.Web.Services.WebMethod>
    Public Shared Function UpdateDisplayOrder(orders As List(Of Object)) As Boolean

        Dim conStr As String = "server=.;database=ColorsHomeTaskDB;integrated security=SSPI"
        Using con As New SqlConnection(conStr)
            Dim sql As String
            sql = "UPDATE Colors SET DisplayOrder = @DisplayOrder WHERE ColorID = @ColorID"
            con.Open()
            Using transaction As SqlTransaction = con.BeginTransaction()
                For Each order In orders
                    Using cmd As New SqlCommand(sql, con, transaction)
                        cmd.Parameters.AddWithValue("@DisplayOrder", order("DisplayOrder"))
                        cmd.Parameters.AddWithValue("@ColorID", order("ColorId"))
                        cmd.ExecuteNonQuery()
                    End Using
                Next
                transaction.Commit()
                Return True
            End Using
        End Using


    End Function

    <System.Web.Services.WebMethod>
    Public Shared Function DeleteColor(colorId As Integer) As Boolean

        Dim conStr As String = "server=.;database=ColorsHomeTaskDB;integrated security=SSPI"
        Using con As New SqlConnection(conStr)
            Dim sql As String
            sql = "Delete From Colors Where ColorID=@ColorId"
            Using cmd As New SqlCommand(sql, con)
                cmd.Parameters.AddWithValue("@ColorId", colorId)
                con.Open()
                Return cmd.ExecuteNonQuery() > 0
            End Using

        End Using


    End Function

    <System.Web.Services.WebMethod>
    Public Shared Function UpdateColor(colorItem As Object) As Boolean

        Dim conStr As String = "server=.;database=ColorsHomeTaskDB;integrated security=SSPI"
        Using con As New SqlConnection(conStr)
            Dim sql As String
            sql = "UPDATE Colors SET ColorName = @ColorName,ColorCode = @ColorCode, Price = @Price WHERE ColorID = @ColorID"
            Using cmd As New SqlCommand(sql, con)
                cmd.Parameters.AddWithValue("@ColorCode", colorItem("colorCode"))
                cmd.Parameters.AddWithValue("@ColorName", colorItem("colorName"))
                cmd.Parameters.AddWithValue("@Price", colorItem("price"))
                cmd.Parameters.AddWithValue("@DisplayOrder", colorItem("displayOrder"))
                cmd.Parameters.AddWithValue("@ColorId", colorItem("colorId"))


                con.Open()
                Return cmd.ExecuteNonQuery() > 0
            End Using
        End Using

    End Function

End Class