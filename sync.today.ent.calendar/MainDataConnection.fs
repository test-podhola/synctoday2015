﻿module MainDataConnection

#if INTERACTIVE
#r "System.Data"
#r "System.Data.Linq"
#r "FSharp.Data.TypeProviders"
#endif

open Common
open System
open System.Data
open System.Data.Linq
open System.Data.SqlClient
open sync.today.Models
open Microsoft.FSharp.Data.TypeProviders

#if OLD_DB
type internal SqlConnection = SqlDataConnection<ConnectionStringName="sync-today-mssql">
let internal db() = SqlConnection.GetDataContext()
let internal cnn() = db().DataContext
#endif

let public getLastSuccessfulDate( date : Nullable<DateTime> ) : DateTime = 
    if date.HasValue then date.Value else DateTime.Now.AddDays(-1.0)

let public getLastSuccessfulDate2( date : Option<DateTime> ) : DateTime = 
    if date.IsSome then date.Value else DateTime.Now.AddDays(-1.0)

let public getDateRange( date : Option<DateTime> ) = 
    if date.IsSome then ( date.Value.AddDays(float -30), DateTime.Now ) else ( DateTime.Now.AddDays(float -30.0), DateTime.Now ) 
