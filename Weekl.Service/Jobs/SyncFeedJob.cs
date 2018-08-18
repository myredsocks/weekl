﻿using System.Threading.Tasks;
using Ninject;
using Quartz;
using Weekl.Service.Worker;

namespace Weekl.Service.Jobs
{
    public class SyncFeedJob : IJob
    {
        public async Task Execute(IJobExecutionContext context)
        {
            var worker = WorkerContainer.Current.Get<IWorker>();
            await Task.Run(() => worker.SyncFeed());
        }
    }
}