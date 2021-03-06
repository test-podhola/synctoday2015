﻿using sync.today.activities;
using System;
using System.Activities;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace sync.today.io.activities
{
    public abstract class BaseDownload : BaseCodeActivity
    {
        public InArgument<Models.ServiceAccountDTO> ServiceAccount { get; set; }
    }
}
