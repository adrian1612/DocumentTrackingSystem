using AAJControl;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;

namespace DocumentTrackingSystem.Classes
{
    public class MasterControl : DBControl
    {
        public MasterControl(string ConnectionString) : base(DatabaseType.MSSQL, ConfigurationManager.ConnectionStrings[ConnectionString].ConnectionString)
        {

        }
    }
}