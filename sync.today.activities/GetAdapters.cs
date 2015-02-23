﻿using System;
using System.Activities;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace sync.today.activities
{
    public sealed class GetAdapters : CodeActivity
    {
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger
    (System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public OutArgument<Models.AdapterDTO[]> result { get; set; }
        protected override void Execute(CodeActivityContext context)
        {
            log.Debug("Entered");
            try
            {
                var adapters = AdapterRepository.Adapters();
                List<Models.AdapterDTO> resultItems = new List<Models.AdapterDTO>(adapters);
                result.Set(context, resultItems.ToArray());
            }
            catch (Exception ex)
            {
                log.Fatal("failed", ex);
                throw;
            }
        }

    }
}
