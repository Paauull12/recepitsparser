import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DentalQuoteComponent } from './dental-quote.component';

describe('DentalQuoteComponent', () => {
  let component: DentalQuoteComponent;
  let fixture: ComponentFixture<DentalQuoteComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [DentalQuoteComponent],
    }).compileComponents();

    fixture = TestBed.createComponent(DentalQuoteComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
