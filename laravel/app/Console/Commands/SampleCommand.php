<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class SampleCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'test:hello-world';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Hello World';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->output->writeln('Hello World!');
        return 0;
    }
}
