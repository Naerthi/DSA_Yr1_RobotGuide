function ctx = subtask1_setup()
%SUBTASK1_SETUP Prepare context for Subtask 1 GUI

    thisFile = fileparts(mfilename('fullpath'));
    repoRoot = fileparts(thisFile);   % subtask1 folder is inside repo root

    [keyP, sigP, result, Position, AngularVelocity] = build_clean_points(repoRoot);

    ctx = struct();
    ctx.repoRoot = repoRoot;
    ctx.keyP = keyP;
    ctx.sigP = sigP;
    ctx.result = result;
    ctx.Position = Position;
    ctx.AngularVelocity = AngularVelocity;
end
