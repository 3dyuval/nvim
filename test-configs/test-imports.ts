// Test file for import ordering

import { CommonModule } from '@angular/common';
import { Component, EventEmitter, inject, Output } from '@angular/core';
import { SelectYearComponent } from '@/components/select-year/select-year.component';
import { AutomationApi } from '@/services/automation/automation-api.service';

@Component({
	selector: 'app-test',
	template: '',
	imports: [CommonModule, SelectYearComponent]
})
export class TestComponent {
	@Output() testEvent = new EventEmitter<void>();

	private api = inject(AutomationApi);
}
