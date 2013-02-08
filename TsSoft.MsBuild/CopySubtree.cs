using System.IO;
using Microsoft.Build.Framework;
using Microsoft.Build.Tasks;
using Microsoft.Build.Utilities;

namespace TSSoft.MsBuild
{
    /// <summary>
    /// http://blogs.byte-force.com/xor/archive/2006/03/02/806.aspx
    /// </summary>
    public class CopySubtree : Copy
    {
        private ITaskItem _sourceRoot;

        public override bool Execute()
        {
            if (DestinationFiles != null)
            {
                Log.LogError("DestinationFiles must not be specified.");
                return false;
            }

            if (DestinationFolder == null)
            {
                Log.LogError("DestinationFolder must be specified.");
                return false;
            }

            if (SourceFiles.Length > 0)
            {
                DestinationFiles = new ITaskItem[SourceFiles.Length];

                string srcRoot = _sourceRoot.GetMetadata("FullPath");
                for (int i = 0; i < SourceFiles.Length; i++)
                {
                    ITaskItem srcFile = SourceFiles[i];
                    string srcPath = srcFile.GetMetadata("FullPath");

                    if (srcPath.StartsWith(srcRoot))
                    {
                        srcPath = srcPath.Substring(srcRoot.Length + 1);
                        srcPath = Path.Combine(DestinationFolder.ItemSpec,
                                                srcPath);
                    }

                    DestinationFiles[i] = new TaskItem(srcPath);
                    srcFile.CopyMetadataTo(DestinationFiles[i]);
                }

                DestinationFolder = null;
            }

            return base.Execute();
        }


        public ITaskItem SourceRoot
        {
            get { return _sourceRoot; }
            set { _sourceRoot = value; }
        }
    }
}