// Test Angular import ordering

import React, { useState } from 'react';
import { CommonModule } from '@angular/common';
import { Component, EventEmitter, inject, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { SelectMonthComponent } from '@/components/select-month/select-month.component';
import { SelectYearComponent } from '@/components/select-year/select-year.component';
import { AutomationApi } from '@/services/automation/automation-api.service';

@Component({
	selector: 'app-test',
	template: '',
	imports: [CommonModule, FormsModule, RouterModule]
})
export class TestComponent {
	@Output() testEvent = new EventEmitter<void>();

	private api = inject(AutomationApi);
}
